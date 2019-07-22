//
//  TDRefreshTableView.swift
//  Refresh_Test
//
//  Created by 杨方明 on 2017/11/1.
//  Copyright © 2017年 杨方明. All rights reserved.
//

import UIKit
import MJRefresh
public let refreshHeaderIdleText = "下拉可以刷新"
public let refreshHeaderPullingText = "松开立即刷新"
public let refreshHeaderRefreshingText = "刷新中..."
public let refreshHeaderEndRefreshText = "刷新完成"

public let refreshFooterIdleText = "上拉加载更多"
public let refreshFooterReleaseToLoadMore = "释放加载更多"
public let refreshFooterRefreshingText = "加载中..."
public let refreshFooterNoMoreText = "没有更多数据"

/// 判断是不是ipad
private let TD_R_IS_IPAD = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad

/// 判断是不是iPhoneX XS
private let TD_IS_IPHONEX = UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 1125, height: 2436), UIScreen.main.currentMode?.size ?? CGSize.zero) && !TD_R_IS_IPAD : false
private let TD_IS_IPHONEXR = UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 828, height: 1792), UIScreen.main.currentMode?.size ?? CGSize.zero) && !TD_R_IS_IPAD : false
private let TD_IS_IPHONEXS_MAX = UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 1242, height: 2688), UIScreen.main.currentMode?.size ?? CGSize.zero) && !TD_R_IS_IPAD : false

/// 判断是不是iPhoneX系列
let R_IS_IPHONEX_SERIES = (TD_IS_IPHONEX || TD_IS_IPHONEXR || TD_IS_IPHONEXS_MAX)

@objc
public protocol TDRefreshDelegate: class {
    @objc optional func beginHeaderRefresh()
    @objc optional func beginFooterRefresh()
}

open class TDRefreshTableView: UITableView {

    private var isHeaderRefresh = true

    public weak var refreshDelegate: TDRefreshDelegate?

    /// 添加下拉刷新，自定义样式，在tableview上方显示动画
    ///
    /// - Parameters:
    ///   - style: 下拉刷新header样式
    ///   - idleText: 初始状态的提示，默认为"下拉可以刷新"
    ///   - pullingText: 下拉状态的提示，默认为"松开立即刷新"
    ///   - refreshingText: 刷新状态的提示，默认为"刷新中..."
    ///   - animations: 刷新动画，动画图片名集合，默认使用动画
    public func addHeaderRefresh(style: HeaderStyle? = .normal,
                                 idleText: String? = refreshHeaderIdleText,
                                 pullingText: String? = refreshHeaderPullingText,
                                 refreshingText: String? = refreshHeaderRefreshingText,
                                 endRefreshText: String? = refreshHeaderEndRefreshText,
                                 animations: [UIImage]? = nil,
                                 themeColor: UIColor? = .lightGray,
                                 imageSize: CGSize? = CGSize(width: 20, height: 20),
                                 animationDuration: TimeInterval? = 2.0) {
        self.mj_header = TDRefreshBeseHeader.configHeader(style: style ?? .normal,
                                                          idleText: idleText,
                                                          pullingText: pullingText,
                                                          refreshingText: refreshingText,
                                                          endRefershText: endRefreshText,
                                                          animations: animations,
                                                          themeColor: themeColor,
                                                          imageSize: imageSize ?? CGSize(width: 20, height: 20),
                                                          animationDuration: animationDuration ?? 2.0,
                                                          refreshingBlock: { [weak self] in
                                                            self?.isHeaderRefresh = true
                                                            self?.refreshDelegate?.beginHeaderRefresh!()
                                                            // 下拉刷新的时候隐藏footerView
                                                            self?.mj_footer?.isHidden = true
        })
    }

    /// 添加下拉刷新，自定义样式
    ///
    /// - Parameters:
    ///   - idleText: 初始状态的提示，默认为"上拉加载更多"
    ///   - refreshingText: 刷新状态的提示，默认为"加载中..."
    ///   - noMoreText: 没有更多状态的提示，默认为"没有更多数据"
    public func addFooterRefresh(idleText: String? = refreshFooterIdleText,
                                 releaseToPulling: String? = refreshFooterReleaseToLoadMore,
                                 refreshingText: String? = refreshFooterRefreshingText,
                                 noMoreText: String? = refreshFooterNoMoreText,
                                 themeColor: UIColor? = .lightGray,
                                 style: FooterStyle? = .normal) {

        self.mj_footer = TDRefreshNormalFooter(refreshingBlock: { [weak self] in
            self?.isHeaderRefresh = false
            self?.refreshDelegate?.beginFooterRefresh!()
        })

        let footer = self.mj_footer as! TDRefreshNormalFooter
        // 负数表示，距离底部多少倍上拉刷新控件高度时，自动触发x上拉刷新
//        footer.triggerAutomaticallyRefreshPercent = -50.0
        footer.ignoredScrollViewContentInsetBottom = R_IS_IPHONEX_SERIES ? 34 : 0
        footer.configFooter(idleText: idleText,
                            refreshingText: refreshingText,
                            releaseToPulling: releaseToPulling,
                            noMoreText: noMoreText,
                            themeColor: themeColor,
                            style: style)
    }

    /// 开始下拉刷新
    public func startHeaderRefresh() {
        // 下拉刷新的时候隐藏footerView
        self.mj_footer?.isHidden = true
        if !self.mj_header.isRefreshing {
            self.mj_header?.beginRefreshing()
        }
    }

    /// 结束刷新，请求失败的时候调用
    public func endRefresh() {
        self.mj_footer?.isHidden = false
        if isHeaderRefresh {
            self.mj_header?.endRefreshing()
        } else {
            self.mj_footer?.endRefreshing()
        }
    }

    /// 结束刷新，上拉刷新为空时调用
    public func endRefreshWhitNoMore() {
        self.mj_footer?.isHidden = false
        self.mj_footer?.endRefreshingWithNoMoreData()
    }

    /// 结束刷新，请求成功的时候调用
    ///
    /// - Parameters:
    ///   - pageSize: 每页数量
    ///   - resultCount: 成功返回结果的数量
    public func endRefresh(resultCount: Int, pageSize: Int) {
        if isHeaderRefresh {
            self.mj_header?.endRefreshing()
            self.mj_footer?.resetNoMoreData()
            if resultCount < pageSize {
                self.mj_footer?.isHidden = true
            } else {
                self.mj_footer?.isHidden = false
            }
        } else {
            if resultCount < pageSize {
                self.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                self.mj_footer?.endRefreshing()
            }
        }
    }
}
