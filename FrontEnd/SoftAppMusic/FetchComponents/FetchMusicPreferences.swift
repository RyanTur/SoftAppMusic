//
//  FetchMusicPreferences.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/5/24.
//

import Foundation

class FetchMusicPreferences: ObservableObject {
    
    @Published var result: AsyncStatus<MusicPreferences> = .empty
    @Published var musicPreferences: MusicPreferences?
    let pageName = "Music Preferences"
    
    func fetchEmptyPreferences() async {
        // MARK: update with GET call
        do {
            result = .inProgress(page: pageName)
            result = .success(musicPreferences!)
        } catch {
            result = .failure(error)
        }
    }
    
    func fetchUserPreferences(userEmail: String) async {
        // MARK: update with GET call
        do {
            result = .inProgress(page: pageName)
            result = .success(musicPreferences!)
        } catch {
            result = .failure(error)
        }
    }
    
    func updateUserPreferences() {
        // MARK: update with PUT Call
        do {
            result = .inProgress(page: pageName)
            result = .success(musicPreferences!)
        } catch {
            result = .failure(error)
        }
    }
}