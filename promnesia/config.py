from promnesia.common import Source
from promnesia.sources import auto

'''
List of sources to use.

You can specify your own, add more sources, etc.
See https://github.com/karlicoss/promnesia#setup for more information
'''
SOURCES = [
    Source(
        auto.index,
        # just some arbitrary directory with plaintext files
        '/home/dnbias/Documents/brain',
        name='brain',
    ),

    # hypothesis
    # Source(instapaper),
    # Source(twitter.index),
]

FILTERS = [
    'mail.google.com',
    'web.telegram.org/#/im',
    'vk.com/im',
    '192.168.0.',

    # you can use regexes too!
    'redditmedia.com.*.(jpg|png|gif)',
]
