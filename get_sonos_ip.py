#!/usr/bin/env python
# -*- coding: utf-8 -*-

# author: Benjamin Preisig

import soco
import re
import codecs


zone_list = list(soco.discover())

with codecs.open('discovered.csv', "w", "utf-8-sig") as the_file:
    for zone in zone_list:
        print u"Player: {0} at IP: {1}".format(zone.player_name, zone)
        the_file.write(u"Player: {0},{1}\n".format(zone.player_name, zone))