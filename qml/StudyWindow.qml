import QtQuick 1.1
import com.nokia.meego 1.1

Rectangle {
    id: studyWindow
    anchors.fill: parent
    property string deckName: ""
    property string mode: "normal"
    Image {
        fillMode: Image.Tile
        source: "../images/wood.jpg"
    }

    PinchArea {
        id: pinchArea
        anchors.fill: parent
        enabled: true
        pinch.minimumScale: 0.5
        pinch.maximumScale: 6
        onPinchFinished: {
            ankiCard.adjustFonts(pinch.scale);
        } 
    }

    Card {
        id: ankiCard
        width: studyWindow.width * 0.8
        height: studyWindow.height * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
    EaseButtons {
        id: ankiEaseButtons
        anchors.bottom: studyWindow.bottom
    }

    QueryDialog {
        id: finishedDialog
        acceptButtonText: "OK"
        onAccepted: {
            pageStack.pop();
        }
    }

    states: [
        State {
            name: "Finished"
            StateChangeScript {
                name: "onFinished"
                script: {
                    finishedDialog.message = Deck.DeckFinishedMsg();
                    finishedDialog.open();
                }
            }
        },
        State {
            name: "Question"
            PropertyChanges { target: ankiCard; state: "" }
            PropertyChanges { target: ankiEaseButtons; state: "" }
        },
        State{
            name: "Answer"
            PropertyChanges { target: ankiCard; state: "back" }
            PropertyChanges { target: ankiEaseButtons; state: "Show" }
        }
    ]

    function cardClicked() {
        if (state == "Question")
            state = "Answer"
        else
            state = "Question"
    }

    function startStudy() {
        console.log("Start Study");
        Deck.openDeck(deckName);
        Deck.setMode(mode);
        Deck.startSession();
        showNextCard();
    }

    function endStudy() {
        console.log("End Study");
        Deck.stopSession();
        Deck.closeDeck();
    }

    function gotAnswer(quality) {
        Deck.answerCard(quality);
        showNextCard();
        parent.updateStatsInfo();
    }

    function showNextCard() {
        Deck.getCard();
        if (Deck.Finished())
        {
            state = "Finished";
            endStudy(); 
        }
        else
        {
            ankiCard.question = Deck.getQuestion();
            ankiCard.answer = Deck.getAnswer();
            ankiCard.adjustFonts(1);
            ankiEaseButtons.successive = Deck.getCardInfo("successive") > 0; 
            state = "Question";
        }
    }

    Component.onCompleted: {
        ankiCard.clicked.connect(cardClicked);
    }
}
