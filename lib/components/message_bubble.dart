import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';

///The componnet for messages
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
    );
  }
}
