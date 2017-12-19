FROM hypriot/rpi-node:latest
MAINTAINER Karsten Hassel

ENV Origin=/srv/alexa-avs-sample-app
RUN mkdir - p $Origin

# Preconfigured variables
ENV OS=rpi
ENV Origin=/srv/alexa-avs-sample-app
ENV Samples_Loc=$Origin/samples
ENV Java_Client_Loc=$Samples_Loc/javaclient
ENV Wake_Word_Agent_Loc=$Samples_Loc/wakeWordAgent
ENV Companion_Service_Loc=$Samples_Loc/companionService
ENV Kitt_Ai_Loc=$Wake_Word_Agent_Loc/kitt_ai
ENV Sensory_Loc=$Wake_Word_Agent_Loc/sensory
ENV External_Loc=$Wake_Word_Agent_Loc/ext

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y git libasound2-dev libatlas-base-dev wiringpi alsa-utils cmake nano && ldconfig

RUN git clone --depth 1 -b master --single-branch https://github.com/alexa/alexa-avs-sample-app.git $Origin

RUN mkdir -p $Kitt_Ai_Loc && mkdir -p $Sensory_Loc && mkdir -p $External_Loc

RUN cd $Kitt_Ai_Loc && git clone --depth 1 -b master --single-branch https://github.com/Kitt-AI/snowboy.git

RUN cd $Sensory_Loc && git clone --depth 1 -b master --single-branch https://github.com/Sensory/alexa-rpi.git

RUN cd $Origin

RUN apt-get install -y vlc vlc-nox vlc-data
RUN sh -c "echo \"/usr/lib/vlc\" >> /etc/ld.so.conf.d/vlc_lib.conf"
RUN sh -c "echo \"VLC_PLUGIN_PATH=\"/usr/lib/vlc/plugin\"\" >> /etc/environment"

RUN mkdir $Java_Client_Loc/lib && Target_Lib=`ldconfig -p | grep libvlc.so | sort | tail -n 1 | rev | cut -d " " -f 1 | rev` \
 && ln -s $Target_Lib $Java_Client_Loc/lib/libvlc.so && ldconfig

RUN ln -s /usr/bin/nodejs /usr/bin/node && node -v

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

RUN echo "========== Installing Java Client ==========" \
RUN rm -rf $Java_Client_Loc/install-java8.sh
COPY install-java8.sh $Java_Client_Loc
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN chmod +x $Java_Client_Loc/install-java8.sh
RUN cd $Java_Client_Loc && bash ./install-java8.sh && cd $Origin

RUN echo "========== Preparing External dependencies for Wake Word Agent ==========" \
 && mkdir $External_Loc/include && mkdir $External_Loc/lib && mkdir $External_Loc/resources \
 && cp $Kitt_Ai_Loc/snowboy/include/snowboy-detect.h $External_Loc/include/snowboy-detect.h \
 && cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/include/portaudio.h $External_Loc/include/portaudio.h \
 && cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/include/pa_ringbuffer.h $External_Loc/include/pa_ringbuffer.h \
 && cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/include/pa_util.h $External_Loc/include/pa_util.h \
 && cp $Kitt_Ai_Loc/snowboy/lib/$OS/libsnowboy-detect.a $External_Loc/lib/libsnowboy-detect.a \
 && cp $Kitt_Ai_Loc/snowboy/examples/C++/portaudio/install/lib/libportaudio.a $External_Loc/lib/libportaudio.a \
 && cp $Kitt_Ai_Loc/snowboy/resources/common.res $External_Loc/resources/common.res \
 && cp $Kitt_Ai_Loc/snowboy/resources/alexa/alexa-avs-sample-app/alexa.umdl $External_Loc/resources/alexa.umdl \
 && ln -s /usr/lib/atlas-base/atlas/libblas.so.3 $External_Loc/lib/libblas.so.3 \
 && $Sensory_Loc/alexa-rpi/bin/sdk-license file $Sensory_Loc/alexa-rpi/config/license-key.txt $Sensory_Loc/alexa-rpi/lib/libsnsr.a $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-20500.snsr $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-21000.snsr $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-31000.snsr \
 && cp $Sensory_Loc/alexa-rpi/include/snsr.h $External_Loc/include/snsr.h \
 && cp $Sensory_Loc/alexa-rpi/lib/libsnsr.a $External_Loc/lib/libsnsr.a \
 && cp $Sensory_Loc/alexa-rpi/models/spot-alexa-rpi-31000.snsr $External_Loc/resources/spot-alexa-rpi.snsr \
 && mkdir $Wake_Word_Agent_Loc/tst/ext \
 && cp -R $External_Loc/* $Wake_Word_Agent_Loc/tst/ext \
 && cd $Origin

RUN echo "========== Compiling Wake Word Agent ==========" \
 && cd $Wake_Word_Agent_Loc/src && cmake . && make -j4 \
 && cd $Wake_Word_Agent_Loc/tst && cmake . && make -j4

RUN cd $Java_Client_Loc && mvn validate && mvn install && cd $Origin

RUN echo "========== Installing Companion Service ==========" \
  && cd $Companion_Service_Loc && npm install && cd $Origin

RUN echo "========== überflüssige Ordner löschen ==========" \
  && rm -rf $Samples_Loc/iOSCompanionApp \
  && rm -rf $Samples_Loc/androidCompanionApp
  
  
RUN chown -R root:root $Origin && chown -R root:root /root/.asoundrc && cd $Origin

WORKDIR $Origin

COPY entrypoint.sh $Origin
RUN cd $Origin && chmod +x entrypoint.sh
