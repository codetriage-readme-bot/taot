/*
 *  The Advanced Online Translator.
 *  Copyright (C) 2013  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
 *
 *  $Id: $Format:%h %ai %an$ $
 *
 *  This file is part of The Advanced Online Translator.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import com.nokia.symbian 1.1
import taot 1.0

Page {
    // A hack for text item to loose focus when clicked outside of it
    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.debug("CLICKED!!!");
            focus = true;
        }
    }

    XmlListModel {
        id: sourceLangs

        function getLangName(code)
        {
            for (var k = 0; k < count; k++)
                if (get(k).code === code)
                    return get(k).name;
            return qsTr("Unknown")
        }

        function getLangIndex(code)
        {
            for (var k = 0; k < count; k++)
                if (get(k).code === code)
                    return k;
            return -1
        }

        source: Qt.resolvedUrl("langs.xml")
        query: "/LanguagePairs/Pair"
        onQueryChanged: reload();

        XmlRole { name: "name"; query: "@source_name/string()" }
        XmlRole { name: "code"; query: "@source_id/string()" }
    }

    XmlListModel {
        id: targetLangs

        function getLangName(code)
        {
            for (var k = 0; k < count; k++)
                if (get(k).code === code)
                    return get(k).name;
            return qsTr("Unknown")
        }

        function getLangIndex(code)
        {
            for (var k = 0; k < count; k++)
                if (get(k).code === code)
                    return k;
            return -1
        }

        source: Qt.resolvedUrl("langs.xml")
        query: "/LanguagePairs/Pair[not(@source_id='auto')]"
        onQueryChanged: reload();

        XmlRole { name: "name"; query: "@source_name/string()" }
        XmlRole { name: "code"; query: "@source_id/string()" }
    }

    SelectionDialog {
        id: fromDialog
        titleText: qsTr("Select the source language")
        selectedIndex: 0
        model: sourceLangs
        delegate: MenuItem {
            text: model.name
            privateSelectionIndicator: selectedIndex == index
            onClicked: {
                selectedIndex = index;
                translator.sourceLanguage = model.code;
                fromDialog.accept();
            }
        }
    }

    SelectionDialog {
        id: toDialog
        titleText: qsTr("Select the target language")
        selectedIndex: 0
        model: targetLangs
        delegate: MenuItem {
            text: model.name
            privateSelectionIndicator: selectedIndex == index
            onClicked: {
                selectedIndex = index;
                translator.targetLanguage = model.code;
                toDialog.accept();
            }
        }
    }

    Column {
        id: col
        spacing: platformStyle.paddingMedium
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: platformStyle.paddingMedium
        }

        Row {
            width: parent.width

            SelectionListItem {
                width: parent.width / 2
                title: qsTr("From");
                subTitle: sourceLangs.getLangName(translator.sourceLanguage);

                onClicked: {
                    fromDialog.selectedIndex = sourceLangs.getLangIndex(translator.sourceLanguage);
                    fromDialog.open();
                }
            }
            SelectionListItem {
                width: parent.width / 2
                title: qsTr("To")
                subTitle: targetLangs.getLangName(translator.targetLanguage)

                onClicked: {
                    toDialog.selectedIndex = targetLangs.getLangIndex(translator.targetLanguage);
                    toDialog.open();
                }
            }
        }

        Timer {
            id: timer
            interval: 1500

            onTriggered: {
                if (source.text !== "")
                    translator.translate();
            }
        }

        TextArea {
            id: source

            width: parent.width
//            text: "Welcome"
            placeholderText: qsTr("Enter the source text...")
            focus: true

//            Keys.onReturnPressed: translator.translate();
//            Keys.onEnterPressed: translator.translate();

            onTextChanged: timer.restart();
        }
        TextArea {
            id: trans

            width: parent.width
            text: translator.translatedText
//            wrapMode: Text.WordWrap
            readOnly: true
        }
        Row {
            id: detectedLanguage

            width: parent.width
            height: childrenRect.height
            spacing: platformStyle.paddingSmall
            state: "Empty"
            clip: true

            Label {
                font.weight: Font.Light
                text: qsTr("Detected language:")
            }
            Label {
                id: dl
                text: sourceLangs.getLangName(translator.detectedLanguage)
            }

            states: [
                State {
                    name: "Empty"
                    when: translator.detectedLanguage === ""

                    PropertyChanges {
                        target: detectedLanguage
                        height: 0
                        opacity: 0
                        scale: 0
                    }
                    PropertyChanges {
                        target: dl
                        text: ""
                    }
                }
            ]

            transitions: [
                Transition {
                    from: ""
                    to: "Empty"

                    ParallelAnimation {
                        NumberAnimation {
                            target: detectedLanguage
                            property: "height"
                            duration: 1300
                            easing.type: Easing.OutBack
                        }
                        SequentialAnimation {
                            PauseAnimation {
                                duration: 1300
                            }
                            PropertyAction {
                                targets: [detectedLanguage,dl]
                                properties: "scale,opacity,text"
                            }
                        }
                    }
                },
                Transition {
                    from: "Empty"
                    to: ""

                    SequentialAnimation {
                        PropertyAction {
                            targets: [detectedLanguage,dl]
                            properties: "height,text"
                        }
                        NumberAnimation {
                            target: detectedLanguage
                            properties: "scale,opacity"
                            duration: 300
                            easing.type: Easing.OutBack
                        }
                    }
                }
            ]
        }
    }

    BusyIndicator {
        width: platformStyle.graphicSizeLarge
        height: width
        visible: translator.busy
        running: visible
        anchors {
            top: col.bottom
            topMargin: platformStyle.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
    }

    ScrollDecorator {
        flickableItem: listDictionary
    }

    ListView {
        id: listDictionary

        clip: true
        model: translator.dictionary
        spacing: platformStyle.paddingSmall
        interactive: count > 0
        cacheBuffer: 100 * platformStyle.paddingMedium
        anchors {
            top: col.bottom
            topMargin: platformStyle.paddingMedium
            left: parent.left
            leftMargin: platformStyle.paddingMedium
            bottom: parent.bottom
            right: parent.right
        }

        delegate: DictionaryDelegate {}
    }

    tools: ToolBarLayout {
        ToolButton {
            iconSource: Qt.resolvedUrl("icons/close.svg")
            onClicked: Qt.quit();
        }
        ToolButton {
            text: qsTr("Translate")
            onClicked: translator.translate();
        }
        ToolButton {
            iconSource: "toolbar-menu"
            onClicked: mainMenu.open();
        }
    }

    Menu {
        id: mainMenu

        MenuLayout {
            MenuItem {
                text: qsTr("About")
                onClicked: aboutDialog.open();
            }
        }
    }

    QueryDialog {
        id: aboutDialog

        titleText: "<b>The Advanced Online Translator</b> v%1".arg(translator.version)
        acceptButtonText: qsTr("Ok")
        privateCloseIcon: true

        message: "<p>Copyright &copy; 2013 <b>Oleksii Serdiuk</b> &lt;contacts[at]oleksii[dot]name&gt;</p>
<p>&nbsp;</p>
<p>The Advanced Online Translator uses available online translation
services to provide translations. Currently it supports only Google
Translate but more services are in the plans (i.e., Bing Translate,
Yandex Translate, etc.).</p>

<p>For Google Translate alternative and reverse translations are displayed
for single words.</p>
<p>&nbsp;</p>
<p>This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.</p>

<p>This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.</p>

<p>You should have received a copy of the GNU General Public License
along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.</p>"
    }

    Translator {
        id: translator

        sourceText: source.text
//        service: "Yandex"

        onError: {
            console.debug(errorString);
            banner.text = errorString;
            banner.open();
        }
    }
}