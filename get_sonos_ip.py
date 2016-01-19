#!/usr/bin/env python
# -*- coding: utf-8 -*-

# author: Benjamin Preisig

import soco
import re


zone_list = list(soco.discover())
for zone in zone_list:
    print u"Player: {0} at IP: {1}".format(zone.player_name, zone)