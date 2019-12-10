#!/venv/bin/python3

from subprocess import (
    CalledProcessError,
    run,
)
import sys

from nexuscli.nexus_client import (
    NexusClient,
    NexusConfig,
)
# https://nexus3-cli.readthedocs.io/en/latest/nexuscli.api.html
# from nexuscli.api.repository import Repository
from nexuscli.api.repository.model import (
    MavenHostedRepository,
    PypiHostedRepository,
)
from nexuscli.api.cleanup_policy.model import CleanupPolicy
from nexuscli.exception import NexusClientInvalidCleanupPolicy


################################################################################
# Ensure admin password is admin123, requires a restart of Nexus
################################################################################

try:
    nexus = NexusClient(NexusConfig(url='http://localhost:8081/nexus'))
except Exception:
    print('Login failed, resetting admin password to admin123',
        file=sys.stderr, flush=True)
    try:
        # https://docs.hakuna.cloud/blog/lost-nexus3-admin-password.html
        r = run([
            'java',
            '-jar',
            './lib/support/nexus-orient-console.jar',
            'connect plocal:/nexus-data/db/security admin admin; update user SET '
            'password="$shiro1$SHA-512$1024$NE+wqQq/TmjZMvfI7ENh/g==$V4yPw8T64UQ6'
            'GfJfxYq2hLsVrBY8D1v+bktfOxGdt4b/9BthpWPNUy/CBk6V9iA0nHpzYzJFWO8v/tZF'
            'tES8CA==" UPSERT WHERE id="admin"; exit',
            ],
            cwd='/opt/sonatype/nexus',
            check=True,
        )
    except CalledProcessError as e:
        # Returns 1 regardless of whether command succeeded or failed
        if e.returncode != 1:
            raise
    print('Stopping nexus, you will need to restart it',
        file=sys.stderr, flush=True)
    run(['kill', '1'], check=True)
    sys.exit(1)


################################################################################
# Create repositories
################################################################################

repos = nexus.repositories.raw_list()
repo_names = set(r['name'] for r in repos)

try:
    cp = nexus.cleanup_policies.get_by_name('default-14d')
    print('default-14d cleanup policy already exists')
except NexusClientInvalidCleanupPolicy:
    print('Creating default-14d cleanup policy')
    cp = CleanupPolicy(
        client=None,
        name='default-14d',
        format='all',
        mode='delete',
        criteria={'lastBlobUpdated': 14},
    )
    nexus.cleanup_policies.create_or_update(cp)

if 'maven-internal' not in repo_names:
    print('Creating maven-internal')
    r = MavenHostedRepository(
        'maven-internal',
        nexus_client=nexus,
        cleanup_policy='default-14d',
    )
    nexus.repositories.create(r)
else:
    print('maven-internal already exists')

if 'pypi-internal' not in repo_names:
    print('Creating pypi-internal')
    r = PypiHostedRepository(
        name='pypi-internal',
        # BUG: Should be automatically set by the Class but it's not
        recipe='pypi',
        nexus_client=nexus,
        cleanup_policy='default-14d',
    )
    nexus.repositories.create(r)
else:
    print('pypi-internal already exists')

