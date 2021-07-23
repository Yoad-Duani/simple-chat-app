import 'package:flash_chat_new/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'file:///C:/yoad-new/study/flutter/FlutterCourseAngela/flash_chat_new/lib/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flash_chat_new/components/message_bubble.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;
ScrollController _scrollController;
int numMessagesInChat;
int currentMax;
bool moreMessages = true;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // _currentMax = 20;
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;

  @override
  void initState() {
    _scrollController = ScrollController();
    numMessagesInChat = 0;
    currentMax = 30;
    super.initState();
    getCurrentUser();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (numMessagesInChat == currentMax) {
          getMoreData();
        } else {
          print('no more messages to load');
        }
      }
    });
  }

  getMoreData() {
    // for (int i = _currentMax; i < _currentMax + 10; i++) {}
    currentMax = currentMax + 25;
    if (mounted) setState(() {});

    print('get more data');
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  bool getIsRead() {
    //FirebaseFirestore.instance.collection('collection_name').doc('document_id').update({'field_name': 'Some new data'});
    _firestore.collection('collectionPath').doc('').update({'': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // messagesStream();
                _auth.signOut();
                Navigator.popUntil(context, ModalRoute.withName(WelcomeScreen.id));
              }),
        ],
        title: Text('Private Chat'),
        backgroundColor: Color(0xff075E54),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/chat_background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: kMessageContainerDecoration,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: messageTextController,
                                  onChanged: (value) {
                                    messageText = value;
                                  },
                                  decoration: kMessageTextFieldDecoration,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Color(0xff128C7E),
                                    boxShadow: [
                                      // BoxShadow(color: Colors.green, spreadRadius: 3),
                                    ],
                                  ),

                                  // color: Color(0xff128C7E),
                                  child: IconButton(
                                    onPressed: () {
                                      messageTextController.clear();
                                      //Implement send functionality.
                                      _firestore.collection('messages').add({
                                        'text': messageText,
                                        'sender': loggedInUser.email,
                                        'timestamp': FieldValue.serverTimestamp(),
                                        'isRead': false,
                                      });
                                    },
                                    icon: Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                                    // child: Text(
                                    //   'Send',
                                    //   style: kSendButtonTextStyle,
                                    // ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

class MessagesStream extends StatelessWidget {
  String getMessageTime(var timeStamp) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(timeStamp.millisecondsSinceEpoch);
    var formatTime = new DateFormat('HH:mm');
    var timeString = formatTime.format(date);
    return timeString;
  }

  @override
  Widget build(BuildContext context) {
    numMessagesInChat = 0;
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy('timestamp', descending: true).limit(currentMax).snapshots(),
      //descending: false
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final messages = snapshot.data.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.get('text');
          final messageSender = message.get('sender');
          final messageTime = message.get('timestamp') == null ? getMessageTime(DateTime.now()) : getMessageTime(message.get('timestamp'));
          final messageIsRead = message.get('isRead') == null ? false : message.get('isRead');

          final currentUser = loggedInUser.email;

          // if (currentUser == messageSender) {}
          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
            messageTime: messageTime,
            isRead: messageIsRead,
          );
          messageBubbles.add(messageBubble);
          numMessagesInChat = messageBubbles.length;
        }
        // if (messageBubbles.length < currentMax) {
        //   moreMessages = false;
        // }
        return Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            // physics: NeverScrollableScrollPhysics(),
            controller: _scrollController,
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
            itemCount: messageBubbles.length,
            // itemExtent: messageBubbles.length.toDouble(),
            itemBuilder: (context, index) {
              return ListTile(
                title: messageBubbles[messageBubbles.length - 1 - index],
                // title: messageBubbles[index],
              );
            },
            // children: messageBubbles,
          ),
        );

        // return Column();
      },
    );
  }
}
