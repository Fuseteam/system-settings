/*
 * Copyright (C) 2014 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 * Jonas G. Drange <jonas.drange@canonical.com>
 *
*/
import QtQuick 2.0
import GSettings 1.0
import SystemSettings 1.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Column {
    objectName: "multiSim"

    property var sims
    property var poweredSim: {
        var s = null;
        sims.forEach(function (sim) {
            if (sim.connMan.powered === true) {
                s = sim;
            }
        });
        return s;
    }
    property var modems
    property var settings: phoneSettings
    property string prevOnlineModem: ""

    /*  @sim a Sim.qml component containing libqofono bindings
        @prevOnlineModem path to modem that was online before modem reset */
    signal umtsModemChanged (var sim, string prevOnlineModem);

    DataMultiSim {
        anchors { left: parent.left; right: parent.right }
    }

    ListItem.SingleValue {
        text : i18n.tr("Hotspot disabled because Wi-Fi is off.")
        visible: showAllUI && !hotspotItem.visible
    }

    ListItem.SingleValue {
        id: hotspotItem
        text: i18n.tr("Wi-Fi hotspot")
        progression: true
        onClicked: {
            pageStack.push(Qt.resolvedUrl("Hotspot.qml"))
        }
        visible: showAllUI && (actionGroup.actionObject.valid ? actionGroup.actionObject.state : false)
    }

    ListItem.Standard {
        id: dataUsage
        text: i18n.tr("Data usage statistics")
        progression: true
        visible: showAllUI
    }

    ListItem.Divider {}

    ListItem.SingleValue {
        text: i18n.tr("Carriers")
        id: chooseCarrier
        objectName: "carrierApnEntry"
        progression: enabled
        showDivider: false
        onClicked: {
            pageStack.push(Qt.resolvedUrl("../PageCarriersAndApns.qml"), {
                sims: sims
            });
        }
    }

    ListItem.Divider {}

    SimEditor {
        anchors { left: parent.left; right: parent.right }
    }

    ListItem.Divider {}

    DefaultSim {
        anchors { left: parent.left; right: parent.right }
    }

    ListItem.Divider {}

    SettingsItemTitle { text: i18n.tr("Connection type:") }

    Repeater {
        model: sims

        ListItem.ItemSelector {
            id: radio
            property var sim: modelData

            function techToString (tech) {
                var strings = {
                    'gsm': i18n.tr("2G only (saves battery)"),
                    'umts': i18n.tr("2G/3G (faster)"),
                    'lte': i18n.tr("2G/3G/4G (faster)")
                };
                strings['umts_enable'] = strings['umts'];
                return strings[tech];
            }

            // adds umts_enable to an copy of model
            function addUmtsEnableToModel (model) {
                var newModel = model.slice(0);
                newModel.push('umts_enable');
                return newModel;
            }

            expanded: true
            text: sim.title
            model: sim.radioSettings.modemTechnologies
            delegate: OptionSelectorDelegate {
                objectName: sim.path + "_radio_" + modelData
                text: techToString(modelData)
            }
            enabled: sim.radioSettings.technologyPreference !== ""
            selectedIndex: sim.radioSettings.technologyPreference !== "" ?
                model.indexOf(sim.radioSettings.technologyPreference) : -1

            onDelegateClicked: {
                if (model[index] === 'umts_enable') {
                    sim.radioSettings.technologyPreference = 'umts';
                    umtsModemChanged(sim, poweredSim ? poweredSim.path : "");
                    sim.mtkSettings.has3G = true;
                } else {
                    sim.radioSettings.technologyPreference = model[index];
                }
            }

            Connections {
                target: sim.radioSettings
                onTechnologyPreferenceChanged: radio.selectedIndex =
                    sim.radioSettings.modemTechnologies.indexOf(preference)

                onModemTechnologiesChanged: {
                    if ((technologies.indexOf('umts') === -1)
                         && (sim.mtkSettings.has3G === false)) {
                        radio.model = addUmtsEnableToModel(technologies);
                    } else {
                        radio.model = technologies;
                    }
                    radio.selectedIndex = sim.radioSettings.technologyPreference !== "" ?
                        model.indexOf(sim.radioSettings.technologyPreference) : -1
                }
                ignoreUnknownSignals: true
            }

            Component.onCompleted: {
                if ((sim.radioSettings.modemTechnologies.indexOf('umts') === -1)
                     && (sim.mtkSettings.has3G === false)) {
                    radio.model = addUmtsEnableToModel(sim.radioSettings.modemTechnologies);
                } else {
                    radio.model = sim.radioSettings.modemTechnologies;
                }
            }
        }
    }


    GSettings {
        id: phoneSettings
        schema.id: "com.ubuntu.phone"
        Component.onCompleted: {
            // set default names
            var simNames = phoneSettings.simNames;
            var m0 = modems[0];
            var m1 = modems[1];
            if (!simNames[m0]) {
                simNames[m0] = "SIM 1";
            }
            if (!simNames[m1]) {
                simNames[m1] = "SIM 2";
            }
            phoneSettings.simNames = simNames;
        }
    }

    Binding {
        target: sims[0]
        property: "name"
        value: phoneSettings.simNames[modems[0]]
    }

    Binding {
        target: sims[1]
        property: "name"
        value: phoneSettings.simNames[modems[1]]
    }
}
