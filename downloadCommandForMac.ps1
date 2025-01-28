curl -o ScreenConnect_Client.pkg  "https://prod.setup.itsupport247.net/darwin/DPMA/64/Bloomfield-Atlantic_Tomor%27s_Office_macOS_ITSPlatform_TKN7bf933ee-0f40-4980-81ee-4c4612924513/PKG/setup"
curl -Is https://prod.setup.itsupport247.net/darwin/DPMA/64/Bloomfield-Atlantic_Tomor%27s_Office_macOS_ITSPlatform_TKN7bf933ee-0f40-4980-81ee-4c4612924513/PKG/setup | head -n 1

cd Users
cd Shared
curl -k -L https://prod.setup.itsupport247.net/darwin/DPMA/64/Main-Stone_Barns_Center_macOS_ITSPlatform_TKN4365c642-5218-4183-9448-fbd54184a54b/PKG/setup -o ScreenConnect.pkg
sudo installer -pkg "ScreenConnect.pkg" -target /

curl -Is https://en.wikipedia.org/wiki/Pikachu#/media/File:Pok%C3%A9mon_Pikachu_art.png | head -n 1