ARG myimage
FROM $myimage
MAINTAINER Karsten Hassel

# Preconfigured variables
ENV Origin=/srv/alexa-avs-sample-app
ENV Samples_Loc=$Origin/samples \
    TMPWWA=$Origin/tmp
ENV Java_Client_Loc=$Samples_Loc/javaclient \
    Wake_Word_Agent_Loc=$Samples_Loc/wakeWordAgent \
    Companion_Service_Loc=$Samples_Loc/companionService
ENV Kitt_Ai_Loc=$Wake_Word_Agent_Loc/kitt_ai \
    Sensory_Loc=$Wake_Word_Agent_Loc/sensory \
    External_Loc=$Wake_Word_Agent_Loc/ext \
    WIRINGPI_SUDO=""
	
ARG myos
ENV myos=$myos

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y git libasound2-dev libatlas-base-dev alsa-utils cmake nano wget build-essential curl gnupg vlc vlc-nox vlc-data && ldconfig

RUN if [ "$myos" = "rpi" ]; then \
      cd && git clone git://git.drogon.net/wiringPi && cd ~/wiringPi  && ./build; \
    fi
	
	
RUN git clone --depth 1 -b master --single-branch https://github.com/alexa/alexa-avs-sample-app.git $Origin

RUN mkdir -p $Kitt_Ai_Loc && mkdir -p $Sensory_Loc && mkdir -p $External_Loc

RUN cd $Kitt_Ai_Loc && git clone --depth 1 -b master --single-branch https://github.com/Kitt-AI/snowboy.git

RUN cd $Sensory_Loc && git clone --depth 1 -b master --single-branch https://github.com/Sensory/alexa-rpi.git

RUN cd $Origin

RUN sh -c "echo \"/usr/lib/vlc\" >> /etc/ld.so.conf.d/vlc_lib.conf"
RUN sh -c "echo \"VLC_PLUGIN_PATH=\"/usr/lib/vlc/plugin\"\" >> /etc/environment"

RUN mkdir $Java_Client_Loc/lib && Target_Lib=`ldconfig -p | grep libvlc.so | sort | tail -n 1 | rev | cut -d " " -f 1 | rev` \
 && ln -s $Target_Lib $Java_Client_Loc/lib/libvlc.so && ldconfig

RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -
RUN apt-get install -y nodejs && node -v && ldconfig

RUN apt-get install -y maven && mvn -version && ldconfig

RUN echo "========== Downloading and Building Port Audio Library needed for Kitt-Ai Snowboy ==========" \
  && cd $Kitt_Ai_Loc/snowboy/examples/C++ \
  && bash ./install_portaudio.sh && ldconfig
  
RUN cd $Kitt_Ai_Loc/snowboy/examples/C++ \
  && make -j4 \
  && ldconfig \
  && cd $Origin

RUN echo "========== Configuring ALSA Devices ==========" \
 && printf "pcm.!default {\n  type asym\n   playback.pcm {\n     type plug\n     slave.pcm \"hw:0,0\"\n   }\n   capture.pcm {\n     type plug\n     slave.pcm \"hw:1,0\"\n   }\n}" >> /root/.asoundrc

RUN java -version
 
RUN apt-get -y autoremove && apt-get -y remove --purge openjdk-7-jre

RUN echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list && cat /etc/apt/sources.list

RUN apt-get update && ldconfig

RUN echo "========== Installing Java Client ==========" \
 && apt install -t jessie-backports openjdk-8-jdk -y --force-yes \
 && update-java-alternatives --set java-1.8.0-openjdk-armhf \
 && cd $Origin
 
ENV Alpn_Version="8.1.11.v20170118"

RUN rm $Java_Client_Loc/pom.xml && cp $Java_Client_Loc/pom_pi.xml $Java_Client_Loc/pom.xml

RUN sed -i "s/The latest version of alpn-boot that supports .*/The latest version of alpn-boot that supports JDK $Java_Version -->/" $Java_Client_Loc/pom.xml \
 && sed -i "s:<alpn-boot.version>.*</alpn-boot.version>:<alpn-boot.version>$Alpn_Version</alpn-boot.version>:" $Java_Client_Loc/pom.xml

RUN echo "========== Preparing External dependencies for Wake Word Agent ==========" \
 && mkdir $External_Loc/include && mkdir $External_Loc/lib && mkdir $External_Loc/resources \
 && cp $Kitt_Ai_Loc/snowboy/include/snowboy-detect.h $External_Loc/include/snowboy-detect.h \
 && cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/include/portaudio.h $External_Loc/include/portaudio.h \
 && cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/include/pa_ringbuffer.h $External_Loc/include/pa_ringbuffer.h \
 && cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/include/pa_util.h $External_Loc/include/pa_util.h \
 && cp $Kitt_Ai_Loc/snowboy/lib/$myos/libsnowboy-detect.a $External_Loc/lib/libsnowboy-detect.a \
 && cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/lib/libportaudio.a $External_Loc/lib/libportaudio.a \
 && cp $Kitt_Ai_Loc/snowboy/resources/common.res $External_Loc/resources/common.res \
 && cp $Kitt_Ai_Loc/snowboy/resources/alexa/alexa-avs-sample-app/alexa.umdl $External_Loc/resources/alexa.umdl \
 && ln -s /usr/lib/atlas-base/atlas/libblas.so.3 $External_Loc/lib/libblas.so.3
 
RUN if [ "$myos" = "rpi" ]; then \
      $Sensory_Loc/alexa-rpi/bin/sdk-license file $Sensory_Loc/alexa-rpi/config/license-key.txt $Sensory_Loc/alexa-rpi/lib/libsnsr.a $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-20500.snsr $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-21000.snsr $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-31000.snsr; \
    fi
 
RUN cp $Sensory_Loc/alexa-rpi/include/snsr.h $External_Loc/include/snsr.h \
 && cp $Sensory_Loc/alexa-rpi/lib/libsnsr.a $External_Loc/lib/libsnsr.a \
 && cp $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-31000.snsr $External_Loc/resources/spot-alexa-rpi.snsr \
 && mkdir $Wake_Word_Agent_Loc/tst/ext \
 && cp -R $External_Loc/* $Wake_Word_Agent_Loc/tst/ext \
 && cd $Origin

RUN mkdir -p $TMPWWA/src && mkdir -p $TMPWWA/tst
 
COPY ./src/* $TMPWWA/src/
COPY ./tst/* $TMPWWA/tst/

RUN if [ "$myos" = "ubuntu64" ]; then \
      cp -R $TMPWWA/src/* $Wake_Word_Agent_Loc/src/; \
      cp -R $TMPWWA/tst/* $Wake_Word_Agent_Loc/tst/; \
    fi

RUN echo "========== Compiling Wake Word Agent ==========" \
 && cd $Wake_Word_Agent_Loc/src && cmake . && make -j4 \
 && cd $Wake_Word_Agent_Loc/tst && cmake . && make -j4

RUN cd $Java_Client_Loc && mvn validate && mvn install && cd $Origin

RUN echo "========== Installing Companion Service ==========" \
  && cd $Companion_Service_Loc && npm install && cd $Origin

RUN echo "========== überflüssige Ordner löschen ==========" \
  && rm -rf $Samples_Loc/iOSCompanionApp \
  && rm -rf $Samples_Loc/androidCompanionApp
  
RUN apt-get autoremove && apt-get clean  
  
RUN chown -R root:root $Origin && chown -R root:root /root/.asoundrc && cd $Origin

RUN mkdir $Origin/samples_ori && mv $Origin/samples/companionService/ $Origin/samples_ori/companionService/

WORKDIR $Origin

COPY entrypoint.sh $Origin
RUN cd $Origin && chmod +x entrypoint.sh

RUN env
