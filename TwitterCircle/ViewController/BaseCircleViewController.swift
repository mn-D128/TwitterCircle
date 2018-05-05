//
//  BaseCircleViewController.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/20.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import RxSwift
import FontAwesomeKit
import MBProgressHUD
import FSCalendar
import CalculateCalendarLogic

class BaseCircleViewController: UIViewController {

    @IBOutlet private weak var dateBtn: DateButton!
    @IBOutlet private weak var prevBtn: UIButton!
    @IBOutlet private weak var nextBtn: UIButton!
    @IBOutlet private weak var pieChartView: PieChartView!
    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var calendarPopup: UIView!
    @IBOutlet private weak var calendarCloseBtn: UIButton!
    @IBOutlet private weak var calendar: FSCalendar!

    @IBOutlet private weak var titleView: UIView!
    @IBOutlet private weak var nameLbl: UILabel!
    @IBOutlet private weak var screenNameLbl: UILabel!

    private let disposeBag: DisposeBag = DisposeBag()

    private let cal: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    private let dateFormatter: DateFormatter = DateFormatter()
    private let logic: CalculateCalendarLogic = CalculateCalendarLogic()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewDidLoad()
        self.dateControlButtonDidLoad()
        self.calendarPopupDidLoad()

        self.bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationItem.titleView = self.titleView

        self.viewModel().viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.viewModel().viewWillDisappear()
    }

    // MARK: - Private

    private func tableViewDidLoad() {
        self.tableView.setTableEmptyFooterView()
        self.tableView.isExclusiveTouch = true
        self.tableView.register(nibClass: TweetListCell.self)

        let dateFormatter: DateFormatter = DateFormatter(withFormat: "HH:mm:ss",
                                                         locale: "en_US_POSIX")

        self.viewModel().tweetsObservable
            .bind(to: self.tableView.rx.items(cellIdentifier: TweetListCell.className!)) { [weak self] _, element, cell in
                guard let cell: TweetListCell = cell as? TweetListCell,
                    let weakSelf: BaseCircleViewController = self else {
                    return
                }

                if let retweetUser: UserDto = element.retweetedStatus?.user {
                    cell.profileImageUrl = retweetUser.profileImageUrlHttps
                    cell.name = retweetUser.name
                    cell.screenName = retweetUser.screenName.screenName
                } else {
                    cell.profileImageUrl = element.user.profileImageUrlHttps
                    cell.name = element.user.name
                    cell.screenName = element.user.screenName.screenName
                }

                cell.tweet = element.text
                cell.createdAt = dateFormatter.string(from: element.createdAt)
                cell.medias = element.extendedEntities?.medias
                cell.delegate = weakSelf
            }
            .disposed(by: self.disposeBag)

        self.tableView.rx
            .modelSelected(TweetDto.self)
            .subscribe(onNext: { [weak self] element in
                guard let weakSelf = self else {
                    return
                }

                var selectedTweets: [TweetDto] = weakSelf.pieChartView.selectedTweets ?? []
                selectedTweets.append(element)

                weakSelf.pieChartView.selectedTweets = selectedTweets
            }).disposed(by: self.disposeBag)

        self.tableView.rx
            .modelDeselected(TweetDto.self)
            .subscribe(onNext: { [weak self] (element: TweetDto) in
                self?.tweetDeselected(element)
            }).disposed(by: self.disposeBag)
    }

    private func dateControlButtonDidLoad() {
        self.prevBtn.isExclusiveTouch = true
        self.dateBtn.isExclusiveTouch = true
        self.nextBtn.isExclusiveTouch = true

        self.setIconToButton(self.prevBtn,
                             fontAwesome: FAKFontAwesome.arrowLeftIcon(withSize: 20.0))
        self.setIconToButton(self.nextBtn,
                             fontAwesome: FAKFontAwesome.arrowRightIcon(withSize: 20.0))

        self.prevBtn.rx
            .controlEvent(UIControlEvents.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.tableViewScrollToTop()

                let delay: DispatchTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(1)
                DispatchQueue.main.asyncAfter(deadline: delay,
                                              execute: {
                    self?.viewModel().previousDate()
                })
            })
            .disposed(by: self.disposeBag)

        self.nextBtn.rx
            .controlEvent(UIControlEvents.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.tableViewScrollToTop()

                let delay: DispatchTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(1)
                DispatchQueue.main.asyncAfter(deadline: delay,
                                              execute: {
                    self?.viewModel().nextDate()
                })
            })
            .disposed(by: self.disposeBag)

        self.dateBtn.rx
            .controlEvent(UIControlEvents.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let weakSelf: BaseCircleViewController = self else {
                    return
                }

                weakSelf.calendarPopup.frame = weakSelf.view.bounds
                weakSelf.view.addSubview(weakSelf.calendarPopup)
            })
            .disposed(by: self.disposeBag)
    }

    private func calendarPopupDidLoad() {
        self.setIconToButton(self.calendarCloseBtn,
                             fontAwesome: FAKFontAwesome.timesCircleIcon(withSize: 30.0))

        self.calendar.delegate = self
        self.calendar.dataSource = self
        self.calendar.isExclusiveTouch = true
        self.calendarPopup.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]

        self.calendarCloseBtn.rx
            .controlEvent(UIControlEvents.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let weakSelf: BaseCircleViewController = self else {
                    return
                }

                weakSelf.calendarPopup.removeFromSuperview()
            })
            .disposed(by: self.disposeBag)
    }

    private func bindViewModel() {
        self.bindViewModel(self.viewModel(), disposeBag: self.disposeBag)

        self.viewModel().dateDriver
            .drive(onNext: { [weak self] (date: CircleDate) in
                guard let weakSelf: BaseCircleViewController = self,
                    let beginDate: Date = date.beginDate else {
                        return
                }

                let weekDay: Int = weakSelf.cal.component(Calendar.Component.weekday,
                                                          from: beginDate)
                let symbol: String = weakSelf.dateFormatter.shortWeekdaySymbols[weekDay - 1]

                weakSelf.dateBtn.title = String(format: "CIRCLE_DATE".localized,
                                                date.year, date.month, date.day, symbol)

                weakSelf.calendar.setCurrentPage(beginDate, animated: false)
                weakSelf.calendar.select(beginDate)
            })
            .disposed(by: self.disposeBag)

        self.viewModel().tweetsDriver
            .drive(onNext: { [weak self] (tweets: [TweetDto]) in
                guard let weakSelf = self else {
                    return
                }

                weakSelf.pieChartView.tweets = tweets
                weakSelf.pieChartView.startAnimation()
            })
            .disposed(by: self.disposeBag)

        self.viewModel().userDriver
            .drive(onNext: { [weak self] (user: UserDto) in
                self?.nameLbl.text = user.name
                self?.screenNameLbl.text = user.screenName.screenName
            })
            .disposed(by: self.disposeBag)
    }

    private func tableViewScrollToTop() {
        guard 0 < self.tableView.numberOfSections,
            0 < self.tableView.numberOfRows(inSection: 0) else {
            return
        }

        let indexPath: IndexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath,
                                   at: UITableViewScrollPosition.top,
                                   animated: false)
    }

    // MARK: -

    private func setIconToButton(_ btn: UIButton, fontAwesome: FAKFontAwesome) {
        let states: [UIControlState] = [
            UIControlState.normal,
            UIControlState.highlighted
        ]

        for state in states {
            guard let color: UIColor = btn.titleColor(for: state) else {
                continue
            }

            fontAwesome.setAttributes([
                NSAttributedStringKey.foregroundColor: color
            ])
            let image: UIImage = fontAwesome.image(with: btn.frame.size)
            btn.setImage(image, for: state)
        }
    }

    // MARK: -

    private func tweetDeselected(_ tweet: TweetDto) {
        if var selectedTweets: [TweetDto] = self.pieChartView.selectedTweets,
            let index: Int = selectedTweets.index(where: { (selectedTweet: TweetDto) -> Bool in
                return selectedTweet == tweet
            }) {
            selectedTweets.remove(at: index)
            self.pieChartView.selectedTweets = selectedTweets
        }
    }

    // MARK: - Public

    func viewModel() -> BaseCircleViewModel {
        return BaseCircleViewModel(sessionLocalRepos: RLMSessionLocalRepository.shared,
                                   userTimelineRepos: TKUserTimelineRepository.shared,
                                   tweetLocalRepos: RLMTweetLocalRepository.shared)
    }

}

// MARK: - TweetListCellDelegate

extension BaseCircleViewController: TweetListCellDelegate {

    func tweetListCell(_ cell: TweetListCell, didSelectedMedia media: MediaDto) {
        guard let vc: ImageMediaViewController = ImageMediaViewController.instantiateFromStoryboard() else {
            return
        }

        var mediaRect: CGRect = CGRect.zero
        if let indexPath: IndexPath = self.tableView.indexPath(for: cell) {
            var naviBarHeight: CGFloat = self.navigationController?.navigationBar.frame.height ?? 0.0
            if #available(iOS 11, *) {
                let top: CGFloat = self.view.safeAreaInsets.top
                naviBarHeight = top
            }

            let cellRect: CGRect = self.tableView.rectForRow(at: indexPath)
            let minY: CGFloat = self.tableView.frame.minY
            let offsetY: CGFloat = self.tableView.contentOffset.y
            let cellY: CGFloat = naviBarHeight + minY + (cellRect.minY - offsetY)

            if let mediaCellRect: CGRect = cell.rectForMedia(media) {
                mediaRect.origin.x = mediaCellRect.origin.x
                mediaRect.origin.y = cellY + mediaCellRect.origin.y
                mediaRect.size.width = mediaCellRect.size.width
                mediaRect.size.height = mediaCellRect.size.height
            }
        }

        vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        vc.delegate = self
        vc.setMedia(media, rect: mediaRect)

        self.present(vc, animated: false, completion: nil)
    }

}

// MARK: - ImageMediaViewControllerDelegate

extension BaseCircleViewController: ImageMediaViewControllerDelegate {

    func imageMediaViewControllerDidCancel(_ vc: ImageMediaViewController) {
        vc.dismiss(animated: false, completion: nil)
    }

}

// MARK: -

extension BaseCircleViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    // MARK: - FSCalendarDelegate

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.calendarPopup.removeFromSuperview()

        self.tableViewScrollToTop()

        let delay: DispatchTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(1)
        DispatchQueue.main.asyncAfter(deadline: delay,
                                      execute: {
            let circleDate: CircleDate = CircleDate(date: date)
            self.viewModel().setDate(circleDate)
        })
    }

    // MARK: - FSCalendarDelegateAppearance

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let year: Int = self.cal.component(Calendar.Component.year, from: date)
        let month: Int = self.cal.component(Calendar.Component.month, from: date)
        let day: Int = self.cal.component(Calendar.Component.day, from: date)
        let isHoliday: Bool = self.logic.judgeJapaneseHoliday(year: year, month: month, day: day)
        if isHoliday {
            return UIColor.red
        }

        let weekday: Int = self.cal.component(Calendar.Component.weekday, from: date)
        switch weekday {
        // 日曜日
        case 1: return UIColor.red
        // 土曜日
        case 7: return UIColor.blue
        // その他
        default: return nil
        }
    }

}
