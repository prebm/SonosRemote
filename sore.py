#!/usr/bin/env python
# -*- coding: utf-8 -*-

# author: Benjamin Preisig


import logging
import lirc
from soco import SoCo
from soco.exceptions import SoCoException
import config

def is_playing(transport_info):
    state = transport_info['current_transport_state']

    if state == 'PLAYING':
        return True
    elif state == 'PAUSED_PLAYBACK':
        return False
    elif state == 'STOPPED':
        return False


def run():

    sonos = SoCo(config.IP_ADDRESS)
    logging.info(u"Starting: {0}".format(sonos.player_name))

    while True:
        sockid = lirc.init("sore")
        val = lirc.nextcode()
        if val:
            try:
                button = val[0]
                logging.info("hello: {0}".format(button))

                if button == 'play':
                    if not is_playing(sonos.get_current_transport_info()):
                        sonos.play()
                    else:
                        sonos.pause()

                elif button == 'plus':
                    sonos.volume +=  2

                elif button == 'minus':
                    sonos.volume -=  2

                elif button == 'next':
                    sonos.next()

                elif button == 'previous':
                    sonos.previous()

                elif button == 'menu':
                    # play radio station
                    # from sonos.get_favorite_radio_stations():
                    # {u'uri': 'x-sonosapi-stream:s44255?sid=254&flags=8224&sn=0', u'title': 'ORF - Radio Wien'}
                    sonos.play_uri(uri='x-sonosapi-stream:s44255?sid=254&flags=8224&sn=0', title='ORF - Radio Wien', start=True)

            except SoCoException as err:
                logging.error("SoCo Error: {0}".format(err))
                pass
            except:
                logging.error("Error: {0}".format(sys.exc_info()[1]))
                


if __name__ == "__main__":
    # TODO: Logging
    # logging.basicConfig(filename="/home/pi/SonosRemote/sore.log", level=logging.INFO)
    run()
