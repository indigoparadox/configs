#!/bin/bash

qdbus -qt=qt5 org.lxqt.session /LXQtSession stopModule lxqt-panel.desktop && sleep 1 && qdbus -qt=qt5 org.lxqt.session /LXQtSession startModule lxqt-panel.desktop
