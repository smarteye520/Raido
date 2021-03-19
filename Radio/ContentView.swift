//
//  ContentView.swift
//  Radio
//
//  Created by echoLive on 2/5/21.
//

import SwiftUI
import AVFoundation
import MediaPlayer

class RadioStreamer {
    
    var streamingURL: URL
    var  radios = ["https://vintageradio.ice.infomaniak.ch/vintageradio-high.mp3", "https://energyzuerich.ice.infomaniak.ch/energyzuerich-high.mp3", "https://icecast.radio24.ch/vhits",
        "https://icecast.argovia.ch/apop-mp3-srp",
        "https://icecast.radio24.ch/vhits",
        "https://20min.dmd2streaming.com/20minuten_radio_128.mp3"]
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    
    init() {
        self.streamingURL =  URL (string:radios.randomElement()!)!
        
        checkSession()
        self.playerItem = AVPlayerItem(url: self.streamingURL)
        self.player = AVPlayer(playerItem: self.playerItem)
    }

    public func playStreaming() {
        randomizePlayer()
        self.player!.play()
        
//        setupRemoteTransportControls()
//        setupNowPlaying()
    }
    
    public func pauseStreaming() {
        self.player!.pause()
    }
    

    private func randomizePlayer() {
        self.streamingURL =  URL (string:radios.randomElement()!)!
        
        checkSession()

        print ("*** Streaming url = ***", self.streamingURL)
        
        self.playerItem = AVPlayerItem(url: self.streamingURL)
        self.player = AVPlayer(playerItem: self.playerItem)
    }
    
    private func checkSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
//            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try audioSession.setCategory(.playback, mode: .default, options: [ .allowAirPlay])
            print("Playback OK")
            try audioSession.setActive(true)
            print("Session is Active")
        } catch {
            print("Permission error")
            print(error)
        }
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player!.rate == 0.0 {
                self.player!.play()
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player!.rate == 1.0 {
                self.player!.pause()
                return .success
            }
            return .commandFailed
        }
    }


    func setupNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Unknown"

        if let image = UIImage(named: "lockscreen") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.playerItem!.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.playerItem!.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player!.rate

        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

struct ContentView: View {
    @State var streamer : RadioStreamer?
    @State var isPlaying : Bool?
    
    var body: some View {
        
        Spacer()
        Button(action: {
            self.streamer!.playStreaming()
            self.isPlaying = true
            
            self.streamer!.setupRemoteTransportControls()
            self.streamer!.setupNowPlaying()
        }) {
            Image(systemName: "play.circle.fill").resizable()
                .frame(width: 77, height: 77)
                .aspectRatio(contentMode: .fit)
//                .foregroundColor(.buttonColor)
                .foregroundColor(.blue)
        }.onAppear {
            self.streamer = RadioStreamer()
            self.isPlaying = false
        }
        
        Spacer()
        Button(action: {
            self.streamer!.pauseStreaming()
        }) {
            Image(systemName: "pause.circle.fill").resizable()
                .frame(width: 77, height: 77)
                .aspectRatio(contentMode: .fit)
//                .foregroundColor(.buttonColor)
                .foregroundColor(.blue)
        }
        
        Spacer()
        Button(action: {
            self.streamer!.pauseStreaming()
            self.streamer!.playStreaming()
            
//            self.streamer!.setupRemoteTransportControls()
//            self.streamer!.setupNowPlaying()
        }) {
            Image(systemName: "forward.end").resizable()
                .frame(width: 77, height: 77)
                .aspectRatio(contentMode: .fit)
//                .foregroundColor(.buttonColor)
                .foregroundColor(.blue)
        }
        Spacer()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


