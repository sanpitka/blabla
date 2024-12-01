import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls.Material

Window {
    width: 800
    height: 600
    minimumWidth: 400
    minimumHeight: 400
    visible: true
    title: qsTr("Blabla")

    ListModel {
        id: messageModel
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        Rectangle {
            color: 'gray'
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 200
            Layout.maximumWidth:200
            Text {
                anchors.centerIn: parent
                text: "Some space for channels..."
            }
        }

        ColumnLayout {
            ListView {
                id: listView
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true
                model: messageModel
                delegate: ItemDelegate {
                    required property string message
                    required property int index
                    implicitHeight: textElement.height + 10
                    width: listView.width

                    Rectangle {
                        anchors.fill: parent
                        color: mouseArea.pressed ? "lightblue" : "transparent"

                        Text{
                            id:textElement
                            text: message
                            font.pixelSize: 14
                            wrapMode: Text.WordWrap
                            width: parent.width - 10
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            onClicked: {
                                replyToIndex = index;
                                replyToMessage.text = "Replying to: " + message;
                            }
                        }
                    }
                }
            }
            ColumnLayout {
                Text {
                    id: replyToMessage
                    text: ""
                    color: "gray"
                    visible: replyToMessage.text !== ""
                }

                RowLayout {


                    TextField {
                        id: textFieldReply
                        placeholderText: qsTr("Reply")
                        Layout.fillWidth: true
                        onAccepted: buttonReply.clicked()
                    }

                    Button {
                        id: buttonReply
                        text: qsTr("Send")
                        highlighted: true
                        onClicked: {
                            if (server && textFieldReply.text.length > 0) {
                                let replyInfo = replyToIndex !== -1 ? (" (Reply to: #" + replyToIndex + ")") : "";
                                                server.sendMessage(textFieldReply.text + replyInfo);
                                var formattedMessage = server.prepareMessage(textFieldReply.text)
                                messageModel.append({ "message": formattedMessage })
                                textFieldReply.clear()
                                replyToMessage.text = ""; // Clear reply reference after sending
                                replyToIndex = -1; // Reset the reply index
                                listView.positionViewAtEnd()
                            }
                        }
                    }
                }
            }
        }
    }
    property int replyToIndex: -1 // No message selected by default
}

