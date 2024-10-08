//
//  MessageListController.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 22.05.24.
//

import UIKit
import SwiftUI
import Combine

final class MessageListController: UIViewController {
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.backgroundColor = .clear
        view.backgroundColor = .clear
        setUpViews()
        setupMessageListeners()
    }
    
    init(_ viewModel: ChatRoomViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private var viewModel: ChatRoomViewModel
    private var subscriptions = Set<AnyCancellable>()
    private let cellIdentifier = "MessageListControllerCell"
    private var lastScrollPosition: String?
    
    private lazy var pullToRefreshControl: UIRefreshControl = {
        let pullToRefreshControl = UIRefreshControl()
        pullToRefreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return pullToRefreshControl
    }()
    
    private let compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        listConfig.showsSeparators = false
        let section = NSCollectionLayoutSection.list(
            using: listConfig,
            layoutEnvironment: layoutEnvironment
        )
        section.contentInsets.leading = 0
        section.contentInsets.trailing = 0
        /// this is going to reduce inter item spacing
        section.interGroupSpacing = -10
        return section
    }
    
    private lazy var messagesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: compositionalLayout
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.selfSizingInvalidation = .enabledIncludingConstraints
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.refreshControl = pullToRefreshControl
        return collectionView
    }()

    private let backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView(image: .chatbackground)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundImageView
    }()
    
    private let pullDownToRefreshView: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        var imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .black)
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: imageConfig)
        buttonConfig.image = image
        buttonConfig.baseBackgroundColor = .bubbleGreen
        buttonConfig.baseBackgroundColor = .whatsAppBlack
        buttonConfig.imagePadding = 5
        buttonConfig.cornerStyle = .capsule
        let font = UIFont.systemFont(ofSize: 12, weight: .black)
        buttonConfig.attributedTitle = AttributedString("Pull Down", attributes: AttributeContainer([NSAttributedString.Key.font: font]))
        let button = UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
       // button.addTarget(self, action: #selector(pullDownToRefresh), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Methods
    
    private func setUpViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(messagesCollectionView)
        view.addSubview(pullDownToRefreshView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            messagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            pullDownToRefreshView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
        ])
    }
    
    private func setupMessageListeners() {
        let delay = 200
        viewModel.$messages
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                
                self?.messagesCollectionView.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.$scrollToBottomRequest
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] scrollRequest in
                if scrollRequest.scroll {
                    self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: scrollRequest.isAnimated)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$isPaginating
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] isPaginating in
                guard let self, let lastScrollPosition else { return }
                
                if !isPaginating {
                    guard let index = viewModel.messages.firstIndex(where: { $0.id == lastScrollPosition }) else { return }
                    let indexPath = IndexPath(item: index, section: 0)
                    self.messagesCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                    self.pullToRefreshControl.endRefreshing()
                }
            }
            .store(in: &subscriptions)
    }
    
    @objc private func refreshData() {
        lastScrollPosition = viewModel.messages.first?.id
        viewModel.getMessages()
    }
}

// MARK: - UICollectionViewDelegate and UICollectionViewDataSource

extension MessageListController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.clear
        let message = viewModel.messages[indexPath.item]
        let isNewDay = viewModel.isNewDay(for: message, at: indexPath.item)
        let showSenderName = viewModel.showSenderName(for: message, at: indexPath.item)
        cell.contentConfiguration = UIHostingConfiguration {
            BubbleView(message: message, channel: viewModel.channel, isNewDay: isNewDay, showSenderName: showSenderName)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIApplication.dismissKeyboard()
        let message = viewModel.messages[indexPath.item]
        switch message.type {
        case .video:
            guard let videoURLString = message.videoURL,
                  let videoURL = URL(string: videoURLString) else { return }
            viewModel.showMediaPlayer(videoURL)
        default:
            break
        }
    }
}

private extension UICollectionView {
    
    func scrollToLastItem(at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard numberOfItems(inSection: numberOfSections - 1) > 0 else { return }
        
        let lastSectionIndex = numberOfSections - 1
        let lastRowIndex = numberOfItems(inSection: lastSectionIndex) - 1
        let lastRowIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        scrollToItem(at: lastRowIndexPath, at: scrollPosition, animated: animated)
    }
}

#Preview {
    MessageListView(viewModel: ChatRoomViewModel(channel: .placeholder))
        .ignoresSafeArea()
}
