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

    ListModel {
        id: channelModel
        ListElement {
            name: "The best channel"
            privacy: "public"
        }
        ListElement {
            name: "Even better channel"
            privacy: "public"
        }
        ListElement {
            name: "Family chat"
            privacy: "private"
        }
    }

    property string currentChannel: ""

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10

        ColumnLayout {
            Layout.minimumWidth: 200
            Layout.maximumWidth: 200
            Layout.fillHeight: true

            Text {
                text: "Channels"
                font.pixelSize: 18
                font.bold: true
            }

            ListView {
                id: channelView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 200
                Layout.maximumWidth:200
                clip: true
                model: channelModel

                delegate: ItemDelegate {
                    width: channelView.width
                    Rectangle {
                        anchors.fill: parent
                        color: currentChannel === name ? "lightblue" : "transparent" // Highlight selected

                        Text {
                            text: privacy === "private" ? name + " 🔒" : name
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 16
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                currentChannel = name; // Set the selected channel
                                console.log("Selected channel: " + name)
                            }
                        }
                    }
                }
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

// Login Dialog
    Dialog {
        id: loginDialog
        modal: true
        visible: true // Ensure the dialog is shown on startup
        title: qsTr("Login")

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        contentItem: ColumnLayout {
            spacing: 10
            Text {
                text: "Please log in!"
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: usernameField
                placeholderText: qsTr("Username")
                onAccepted: buttonLogin.clicked()
                Layout.fillWidth: true
            }
            TextField {
                id: passwordField
                placeholderText: qsTr("Password")
                echoMode: TextInput.Password
                onAccepted: buttonLogin.clicked()
                Layout.fillWidth: true
            }

            Button {
                id: buttonLogin
                text: qsTr("Login")
                highlighted: true
                onClicked: {
                    if (usernameField.text.length > 0) {
                        server.setUsername(usernameField.text);
                        console.log("Logged in as:", usernameField.text)
                        loginDialog.close() // Close the dialog after login
                    } else {
                        console.log("Username is required")
                    }
                }
            }
        }
    }
}

