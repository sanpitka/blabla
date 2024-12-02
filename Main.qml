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

    // Model to store chat messages
    ListModel {
        id: messageModel
    }

    // Model to store channel information
    ListModel {
        id: channelModel
        //Predefined public and private channels
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

    property string currentChannel: "The best channel"

    // Index of the message being replied to
    property int replyToIndex: -1 // No message selected by default

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10

        // Column for channels
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
                Layout.maximumWidth: 200
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

        // Message column
        ColumnLayout {
            ListView {
                id: messageView
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.topMargin: 30
                clip: true
                model: messageModel

                delegate: ItemDelegate {
                    required property string message
                    required property int index
                    implicitHeight: textElement.height + 10
                    width: messageView.width

                    Rectangle {
                        anchors.fill: parent
                        color: mouseArea.pressed ? "lightblue" : "transparent"

                        Text {
                            id: textElement
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

            // Reply column
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

                    // Button to send a message
                    Button {
                        id: buttonReply
                        text: qsTr("Send")
                        highlighted: true
                        onClicked: {
                            if (server && textFieldReply.text.length > 0) {
                                let replyInfo = replyToIndex !== -1 ? (" (Reply to: #" + replyToIndex + ")") : "";
                                server.sendMessage(textFieldReply.text + replyInfo);

                                var formattedMessage = server.prepareMessage(textFieldReply.text)
                                messageModel.append({ "message": formattedMessage, "index": messageModel.count, "channel": currentChannel })

                                //Print the message info to console
                                   for (var i = 0; i < messageModel.count; i++) {
                                       var item = messageModel.get(i);
                                       console.log("Model Item " + i + ": " + JSON.stringify(item));
                                   }
                                // Reset input and reply state
                                textFieldReply.clear();
                                replyToMessage.text = "";
                                replyToIndex = -1;

                                messageView.positionViewAtEnd();
                            }
                        }
                    }
                }
            }
        }
    }

    // Login Dialog
    Dialog {
        id: loginDialog
        width: 200
        height: 300
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
                        console.log("Logged in as:", usernameField.text);
                        loginDialog.close(); // Close the dialog after login

                        // Add "joined the chat" message
                        messageModel.append({
                            "message": usernameField.text + " joined the chat!",
                            "index": messageModel.count
                        });
                    } else {
                        console.log("Username is required");
                    }
                }
            }
        }
    }
}
