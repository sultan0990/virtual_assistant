import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/models_provider.dart';
import '../providers/chats_provider.dart';
import '../services/api_service.dart';
import '../services/services.dart';
import '../widgets/chat_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatGPT"),
        actions: [
          IconButton(
            onPressed: () async {
              await Services.showModalSheet(context: context);
            },
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                controller: _listScrollController,
                itemCount: chatProvider.getChatList.length,
                itemBuilder: (context, index) {
                  return ChatWidget(
                    msg: chatProvider.getChatList[index].msg,
                    chatIndex: chatProvider.getChatList[index].chatIndex,
                    shouldAnimate: index == chatProvider.getChatList.length - 1,
                  );
                },
              ),
            ),
            _isTyping
                ? Padding(
              padding: const EdgeInsets.all(10.0),
              child: const SpinKitFadingCircle(
                color: Colors.lightBlue,
                size: 30,
              ),
            )
                : Container(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: "Type a message",
                        hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (textEditingController.text.isNotEmpty) {
                        chatProvider.addUserMessage(textEditingController.text, msg: '');
                        setState(() => _isTyping = true);

                        await ApiService.sendMessageGPT(
                          message: textEditingController.text,
                          modelId: modelsProvider.getCurrentModel,
                        );

                        setState(() => _isTyping = false);
                      }
                    },
                    icon: const Icon(Icons.send_rounded, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
