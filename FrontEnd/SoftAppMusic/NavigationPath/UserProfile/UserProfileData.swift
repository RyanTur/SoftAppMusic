//
//  UserProfileData.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/5/24.
//

import Foundation

struct UserProfileData: Codable {
    var email: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var age: String = ""
    var spotifyConsent: Bool = false
}

struct SpotifyLogin: Codable {
    #warning("figure out where this goes")
}
