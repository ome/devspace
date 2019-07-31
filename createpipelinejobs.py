#!/usr/bin/env python

import errno
import os
import yaml


TEMPLATE_CONFIG_XML = 'TEMPLATE-pipeline-job-config.xml'
JENKINS_JOBS_DIR = './home/jobs'

PROPERTIES = """\
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers>
        {TRIGGERS}
      </triggers>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
"""
TRIGGER = """\
        <jenkins.triggers.ReverseBuildTrigger>
          <spec></spec>
          <upstreamProjects>{AFTER_JOBNAME}</upstreamProjects>
          <threshold>
            <name>SUCCESS</name>
            <ordinal>0</ordinal>
            <color>BLUE</color>
            <completeBuild>true</completeBuild>
          </threshold>
        </jenkins.triggers.ReverseBuildTrigger>
"""


def main():
    with open(TEMPLATE_CONFIG_XML) as f:
        template = f.read()
    with open('pipeline-configs.yaml') as f:
        cfg = yaml.load(f)

    for (jobname, jobcfg) in cfg['jobs'].items():
        new_job_dir = os.path.join(JENKINS_JOBS_DIR, jobname)
        new_job_cfg = os.path.join(new_job_dir, 'config.xml')
        print('Creating {} with configuration {}'.format(new_job_cfg, jobcfg))
        if 'after' in jobcfg:
            triggers = [TRIGGER.format(AFTER_JOBNAME=j)
                        for j in jobcfg['after']]
            properties = PROPERTIES.format(TRIGGERS='\n'.join(triggers))
        else:
            properties = ''
        job_config_xml = template.format(
            DESCRIPTION=jobcfg['description'],
            REPOSITORY=jobcfg['repository'],
            BRANCH=jobcfg['branch'],
            CLONE_TIMEOUT=jobcfg.get('clone_timeout', 10),
            JENKINSFILE=jobcfg.get('jenkinsfile', 'Jenkinsfile'),
            PROPERTIES=properties,
        )
        try:
            os.mkdir(new_job_dir)
        except OSError as e:
            if e.errno != errno.EEXIST:
                raise
        if os.path.exists(new_job_cfg):
            raise Exception("exists: " + new_job_cfg)
        with open(new_job_cfg, 'w') as f:
            f.write(job_config_xml)


if __name__ == '__main__':
    main()
