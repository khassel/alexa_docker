# Remove any existing Java
apt-get -y autoremove
apt-get -y remove --purge oracle-java8-jdk oracle-java7-jdk openjdk-7-jre openjdk-8-jre

# Install Java from Ubuntu's PPA
# http://linuxg.net/how-to-install-the-oracle-java-8-on-debian-wheezy-and-debian-jessie-via-repository/
sh -c "echo \"deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main\" >> /etc/apt/sources.list"
sh -c "echo \"deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main\" >> /etc/apt/sources.list"

KEYSERVER=(pgp.mit.edu keyserver.ubuntu.com)

GPG_SUCCESS="false"
for server in ${KEYSERVER[@]}; do
  COMMAND="apt-key adv --keyserver ${server} --recv-keys EEA14886"
  echo $COMMAND
  $COMMAND
  if [ "$?" -eq "0" ]; then
    GPG_SUCCESS="true"
    break
  fi
done

if [ "$GPG_SUCCESS" == "false" ]; then
  echo "ERROR: FAILED TO FETCH GPG KEY. UNABLE TO UPDATE JAVA"
fi

apt-get update
apt-get -y install oracle-java8-installer
apt-get -y install oracle-java8-set-default

Java_Version=`java -version 2>&1 | awk 'NR==1{ gsub(/"/,""); print $3 }'`
echo "java version: $Java_Version "
Java_Major_Version=$(echo $Java_Version | cut -d '_' -f 1)
Java_Minor_Version=$(echo $Java_Version | cut -d '_' -f 2)
echo "major version: $Java_Major_Version minor version: $Java_Minor_Version"

Alpn_Version=""
if [ "$Java_Major_Version" = "1.8.0" ] && [ "$Java_Minor_Version" -gt 59 ]; then
if [ "$Java_Minor_Version" -gt 120 ]; then
  Alpn_Version="8.1.11.v20170118"
elif [ "$Java_Minor_Version" -gt 111 ]; then
  Alpn_Version="8.1.10.v20161026"
elif [ "$Java_Minor_Version" -gt 100 ]; then
  Alpn_Version="8.1.9.v20160720"
elif [ "$Java_Version" == "1.8.0_92" ]; then
  Alpn_Version="8.1.8.v20160420"
elif [ "$Java_Minor_Version" -gt 70 ]; then
  Alpn_Version="8.1.7.v20160121"
elif [[ $Java_Version ==  "1.8.0_66" ]]; then
  Alpn_Version="8.1.6.v20151105"
elif [[ $Java_Version ==  "1.8.0_65" ]]; then
  Alpn_Version="8.1.6.v20151105"
elif [[ $Java_Version ==  "1.8.0_60" ]]; then
  Alpn_Version="8.1.5.v20150921"
fi
else
echo "Unsupported or unknown java version ($Java_Version), defaulting to latest known ALPN."
Echo "Check http://www.eclipse.org/jetty/documentation/current/alpn-chapter.html#alpn-versions to get the alpn version matching your JDK version."
read -t 10 -p "Hit ENTER or wait ten seconds"
fi

rm $Java_Client_Loc/pom.xml
cp $Java_Client_Loc/pom_pi.xml $Java_Client_Loc/pom.xml

sed -i "s/The latest version of alpn-boot that supports .*/The latest version of alpn-boot that supports JDK $Java_Version -->/" $Java_Client_Loc/pom.xml
sed -i "s:<alpn-boot.version>.*</alpn-boot.version>:<alpn-boot.version>$Alpn_Version</alpn-boot.version>:" $Java_Client_Loc/pom.xml
