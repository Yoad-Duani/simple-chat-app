import 'package:flash_chat_new/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_new/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
    // DateTime date1 = new DateTime(timeStamp.millisecondsSinceEpoch).toUtc();
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

        //FirebaseFirestore.instance.collection('collection_name').doc('document_id').update({'field_name': 'Some new data'});

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

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe, this.messageTime, this.isRead});

  final String sender;
  final String text;
  final bool isMe;
  final String messageTime;
  final bool isRead;

  Row getIconDone_All() {
    return Row(
      children: [
        SizedBox(
          width: 5.0,
        ),
        Icon(
          Icons.done_all,
          size: 20.0,
          color: isRead == false ? Colors.grey : Color(0xff34B7F1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
      child: Bubble(
        margin: BubbleEdges.only(top: 10),
        alignment: isMe ? Alignment.topRight : Alignment.topLeft,
        nip: isMe ? BubbleNip.rightBottom : BubbleNip.leftTop,
        color: isMe ? Color.fromRGBO(225, 255, 199, 1.0) : Colors.white,
        radius: Radius.circular(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMe == false)
              Text(
                sender.substring(0, sender.indexOf('@')),
                style: TextStyle(fontSize: 15.0, color: Colors.pink[200]),
              ),
            SizedBox(
              height: 3.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              // textBaseline: TextBaseline.alphabetic,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        text,
                        textAlign: isMe ? TextAlign.left : TextAlign.left,
                        style: TextStyle(fontSize: 18.0),
                        // overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 14.0,
                ),
                Row(
                  children: [
                    Text(
                      messageTime,
                      style: TextStyle(color: Colors.black38, fontSize: 13),
                    ),
                    if (isMe == true) getIconDone_All(),
                  ],
                ),
              ],
            ),
            // Text('${messageTime == null ? DateTime.now().hour : messageTime.toDate().hour} '),
          ],
        ),
      ),
      // child: Column(
      //   crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      //   children: [
      //     Text(
      //       sender,
      //       style: TextStyle(
      //         fontSize: 12.0,
      //         color: Colors.black45,
      //       ),
      //     ),
      //     Material(
      //       borderRadius: isMe
      //           ? BorderRadius.only(
      //               topLeft: Radius.circular(10.0),
      //               bottomLeft: Radius.circular(10.0),
      //               bottomRight: Radius.circular(10.0),
      //             )
      //           : BorderRadius.only(
      //               topRight: Radius.circular(10.0),
      //               bottomLeft: Radius.circular(10.0),
      //               bottomRight: Radius.circular(10.0),
      //             ),
      //       elevation: 3.0,
      //       color: isMe ? Color(0xffDCF8C6) : Colors.white,
      //       child: Padding(
      //         padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      //         child: Text(
      //           text,
      //           style: TextStyle(
      //             color: isMe ? Colors.black54 : Colors.black54,
      //             fontSize: 16.0,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
