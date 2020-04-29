import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:two_letter_icon/two_letter_icon.dart';

class ChatPage extends StatefulWidget {
  final String name;

  const ChatPage({Key key, this.name}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Room"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection('messages')
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Container(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: LinearProgressIndicator(),
                      ),
                    );

                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildListItem(
                          context, snapshot.data.documents[index]);
                    },
                  );
                }),
          ),
          Card(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      hintText: "Message",
                    ),
                    onEditingComplete: _sendMessage,
                  ),
                )),
                IconButton(
                  icon: Icon(
                    Icons.send,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = Message(
      content: textController.text,
      time: Timestamp.now(),
      author: this.widget.name,
    );
    Firestore.instance.collection("messages").add(message.toMap());

    textController.text = "";
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final message = Message.fromSnapshot(data);
    final isAuthor = message.author == this.widget.name;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment:
            isAuthor ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!isAuthor) TwoLetterIcon(message.author),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Card(
                color: isAuthor ? Colors.grey : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(width: 240, child: Text(message.content)),
                ),
              ),
              Text(
                formatDate(message.time.toDate(), [HH, ':', nn, ':', ss]),
                style: TextStyle(fontSize: 10, color: Colors.grey),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class Message {
  final String content;
  final String author;
  final Timestamp time;

  Message({this.content, this.author, this.time});

  Message.fromMap(Map<String, dynamic> map)
      : this(content: map['content'], author: map['author'], time: map['time']);

  Message.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);

  Map<String, dynamic> toMap() {
    return {"content": content, "author": author, "time": time};
  }
}
