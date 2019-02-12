//
//  Reactionable.swift
//  GetStream-iOS
//
//  Created by Alexey Bukhtin on 12/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

public protocol Reactionable {
    associatedtype ReactionType = ReactionProtocol
    
    /// Include reactions added by current user to all activities.
    var ownReactions: [ReactionKind: [ReactionType]]? { get set }
    /// Include recent reactions to activities.
    var latestReactions: [ReactionKind: [ReactionType]]? { get set }
    /// Include reaction counts to activities.
    var reactionCounts: [ReactionKind: Int]? { get set }
}

extension Reactionable where ReactionType: ReactionProtocol {
    
    /// Update the activity with a new own reaction.
    ///
    /// - Parameter reaction: a new own reaction.
    public mutating func addOwnReaction(_ reaction: ReactionType) {
        var ownReactions = self.ownReactions ?? [:]
        var latestReactions = self.latestReactions ?? [:]
        var reactionCounts = self.reactionCounts ?? [:]
        ownReactions[reaction.kind, default: []].insert(reaction, at: 0)
        latestReactions[reaction.kind, default: []].insert(reaction, at: 0)
        reactionCounts[reaction.kind, default: 0] += 1
        self.ownReactions = ownReactions
        self.latestReactions = latestReactions
        self.reactionCounts = reactionCounts
    }
    
    /// Delete an existing own reaction for the activity.
    ///
    /// - Parameter reaction: an existing own reaction.
    public mutating func deleteOwnReaction(_ reaction: ReactionType) {
        var ownReactions = self.ownReactions ?? [:]
        var latestReactions = self.latestReactions ?? [:]
        var reactionCounts = self.reactionCounts ?? [:]
        
        if let firstIndex = ownReactions[reaction.kind]?.firstIndex(where: { $0.id == reaction.id }) {
            ownReactions[reaction.kind, default: []].remove(at: firstIndex)
            self.ownReactions = ownReactions
            
            if let firstIndex = latestReactions[reaction.kind]?.firstIndex(where: { $0.id == reaction.id }) {
                latestReactions[reaction.kind, default: []].remove(at: firstIndex)
                self.latestReactions = latestReactions
            }
            
            if let count = reactionCounts[reaction.kind], count > 0 {
                reactionCounts[reaction.kind, default: 0] = count - 1
                self.reactionCounts = reactionCounts
            }
        }
    }
}
