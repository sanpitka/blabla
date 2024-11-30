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
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true
                model: messageModel
                delegate: ItemDelegate {
                    required property string message
                    text: message
                }
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
                            server.sendMessage(textFieldReply.text)
                            var formattedMessage = server.prepareMessage(textFieldReply.text)
                            messageModel.append({ "message": formattedMessage })
                            textFieldReply.clear()
                        }
                    }
                }
            }
        }
    }

    Connections {
            target: server

        function onNewMessageReceived(newMessage) {
            console.log("New message received:", newMessage);
            messageListView.model.append({ "message": "Server: " + newMessage });
        }
    }
}
