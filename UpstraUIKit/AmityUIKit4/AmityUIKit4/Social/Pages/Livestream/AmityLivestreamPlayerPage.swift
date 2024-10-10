//
//  AmityLivestreamPlayerPage.swift
//  AmityUIKit4
//
//  Created by Manuchet Rungraksa on 10/10/2567 BE.
//

import SwiftUI

public struct AmityLivestreamPlayerPage: AmityPageView {
    
    let post: AmityPostModel
    
    public var id: PageId {
        .livestreamPlayerPage
    }
    
    public init(post: AmityPostModel) {
        self.post = post
    }
    
    public var body: some View {
        
        if let livestream = post.liveStream {
            if post.livestreamState == .recorded {
                
                RecordedStreamPlayerView(livestream: livestream)
                    .ignoresSafeArea(.all)
                
            } else {
                LivestreamVideoPlayerView(post: post)
                
            }
        }
    }
    
}