claat export 1lV3fqgdWlWI0Goge-w6qcM-xI7MM4dZHdJkmRtoERJY
rm -rf ./public/img
mv ./flutter-chat-codelab/* ./public
rm -rf ./flutter-chat-codelab
firebase deploy --only hosting
