#!/usr/bin/python

import sys

try:
  from collectors.lib import metrics_jmx
except ImportError:
  metrics_jmx = None

if __name__ == "__main__":
  if metrics_jmx is None:
    print >>sys.stderr, "error: metrics_jmx module is missing, tcollector-0.9.0 or greater required"
    sys.exit(13)

  sys.exit(metrics_jmx.start('com.adobe.mcloud.pipeline.producer.ProducerService', '(kafka|com.adobe)'))
