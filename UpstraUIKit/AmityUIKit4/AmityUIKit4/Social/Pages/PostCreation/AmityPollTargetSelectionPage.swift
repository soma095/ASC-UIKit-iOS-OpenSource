//
//  AmityPollTargetSelectionPage.swift
//  AmityUIKit4
//
//  Created by Nishan Niraula on 16/10/2567 BE.
//

import SwiftUI

public struct AmityPollTargetSelectionPage: AmityPageView {
    @EnvironmentObject public var host: AmitySwiftUIHostWrapper
    
    public var id: PageId {
        .pollTargetSelectionPage
    }
    
    @StateObject private var viewConfig: AmityViewConfigController
    private let mytimelineAvatarURL: URL? = URL(string: AmityUIKitManagerInternal.shared.client.user?.snapshot?.getAvatarInfo()?.fileURL ?? "")
    
    public init() {
        self._viewConfig = StateObject(wrappedValue: AmityViewConfigController(pageId: .postTargetSelectionPage))
    }
    
    public var body: some View {
        VStack {
            HStack {
                let closeButton = viewConfig.getConfig(elementId: .closeButtonElement, key: "image", of: String.self) ?? ""
                Image(AmityIcon.getImageResource(named: closeButton))
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(viewConfig.theme.baseColor))
                    .onTapGesture {
                        if let navigationController = host.controller?.navigationController {
                            navigationController.dismiss(animated: true)
                        } else {
                            host.controller?.dismiss(animated: true)
                        }
                    }
                
                Spacer()
            }
            .overlay(
                Text(viewConfig.getConfig(elementId: .title, key: "text", of: String.self) ?? "")
                    .applyTextStyle(.titleBold(Color(viewConfig.theme.baseColor)))
            )
            .padding([.leading, .trailing], 12)
            .frame(height: 58)

            
            TargetSelectionView(headerView: {
                VStack(spacing: 10) {
                    HStack(spacing: 0) {
                        AsyncImage(placeholder: AmityIcon.defaultCommunityAvatar.getImageResource(), url: mytimelineAvatarURL)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 12))
                            .isHidden(viewConfig.isHidden(elementId: .myTimelineAvatar), remove: true)
                            .accessibilityIdentifier(AccessibilityID.Social.PostTargetSelection.myTimelineAvatar)
                            
                        let myTimelineTitle = viewConfig.getConfig(elementId: .myTimelineText, key: "text", of: String.self) ?? ""
                        Text(myTimelineTitle)
                            .applyTextStyle(.bodyBold(Color(viewConfig.theme.baseColor)))
                            .isHidden(viewConfig.isHidden(elementId: .myTimelineText), remove: true)
                            .accessibilityIdentifier(AccessibilityID.Social.PostTargetSelection.myTimelineText)
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        
                        let context = AmityPollTargetSelectionPageBehavior.Context(page: self, community: nil)
                        AmityUIKitManagerInternal.shared.behavior.pollTargetSelectionPageBehavior?.goToPollPostComposerPage(context: context)
                    }
                    
                    Rectangle()
                        .fill(Color(viewConfig.theme.baseColorShade4))
                        .frame(height: 1)
                }
                .padding([.leading, .trailing], 16)
            }, communityOnTapAction: { communityModel in
                let context = AmityPollTargetSelectionPageBehavior.Context(page: self, community: communityModel)
                AmityUIKitManagerInternal.shared.behavior.pollTargetSelectionPageBehavior?.goToPollPostComposerPage(context: context)

            }, contentType: .post)
        }
        .background(Color(viewConfig.theme.backgroundColor).ignoresSafeArea())
        .updateTheme(with: viewConfig)
    }
}

open class AmityPollTargetSelectionPageBehavior {
    
    open class Context {
        public let page: AmityPollTargetSelectionPage
        public let community: AmityCommunityModel?
        
        init(page: AmityPollTargetSelectionPage, community: AmityCommunityModel?) {
            self.page = page
            self.community = community
        }
    }
    
    public init() {}
    
    open func goToPollPostComposerPage(context: AmityPollTargetSelectionPageBehavior.Context) {
        
        let view: AmityPollPostComposerPage
        if let community = context.community {
            view = AmityPollPostComposerPage(targetId: community.communityId, targetType: .community)
        } else {
            view = AmityPollPostComposerPage(targetId: nil, targetType: .user)
        }
        
        let controller = AmitySwiftUIHostingController(rootView: view)
        context.page.host.controller?.navigationController?.pushViewController(controller, animated: true)
    }
}