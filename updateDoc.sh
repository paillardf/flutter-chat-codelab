claat export 18c1582hiapOGwhCoeNBIGhtX3QroNmjJvnPc_25eOGs
rm -rf ./public/img
mv ./rizomm-flutter/* ./public
rm -rf ./rizomm-flutter
firebase deploy --only hosting
