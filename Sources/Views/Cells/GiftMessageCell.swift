//
//  File.swift
//
//
//  Created by fengming on 2022/2/9.
//

import UIKit

/// A subclass of `MessageContentCell` used to display video and audio messages.
open class GiftMessageCell: MessageContentCell {

    lazy var titleLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 0.96, green: 0.88, blue: 0.56,alpha:1)
        return label
    }()
    
    lazy var descriptionLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = UIColor(red: 0.96, green: 0.88, blue: 0.56,alpha:1)
        label.textAlignment = .center
        return label
    }()
    
    /// The image view display the media content.
    open var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // 操作
    open var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
 
    // MARK: - Methods

    /// Responsible for setting up the constraints of the cell's subviews.
    open func setupConstraints() {
        
        backgroundImageView.addConstraints(centerY: self.centerYAnchor,
                                 centerX: self.centerXAnchor,
                                 centerYConstant: 0,
                                 centerXConstant: 0,
                                 widthConstant: 100,
                                 heightConstant: 94)
        
        imageView.addConstraints(centerY: backgroundImageView.centerYAnchor,
                                 centerX: backgroundImageView.centerXAnchor,
                                 centerYConstant: 0,
                                 centerXConstant: 0,
                                 widthConstant: 75,
                                 heightConstant: 75)

        titleLabel.addConstraints(bottom: imageView.centerYAnchor,
                                  bottomConstant: 8,
                                  widthConstant: 80)

        descriptionLabel.addConstraints(imageView.centerYAnchor,
                                        topConstant: 0,
                                        widthConstant: 80)
        
    }

    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(backgroundImageView)
        messageContainerView.addSubview(titleLabel)
        messageContainerView.addSubview(descriptionLabel)
        messageContainerView.addSubview(imageView)
        setupConstraints()
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self.backgroundImageView.image = nil
        self.imageView.image = nil
    }

    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        if dataSource.isFromCurrentSender(message: message) { // outgoing message
            titleLabel.addConstraints(left: backgroundImageView.rightAnchor,
                                      leftConstant: 8)
            descriptionLabel.addConstraints(left: backgroundImageView.rightAnchor,
                                            leftConstant: 8)
            titleLabel.textAlignment = .left
            descriptionLabel.textAlignment = .left
        } else { // incoming message
            titleLabel.addConstraints(right: backgroundImageView.leftAnchor,
                                      rightConstant: 8)
            descriptionLabel.addConstraints(right: backgroundImageView.leftAnchor,
                                            rightConstant: 8)
            titleLabel.textAlignment = .right
            descriptionLabel.textAlignment = .right
        }
        switch message.kind {
        case .gift(let mediaItem):
            backgroundImageView.image = mediaItem.backgroundImage
            imageView.image = mediaItem.image ?? mediaItem.placeholderImage
            titleLabel.text = mediaItem.title
            titleLabel.textColor = .white
            
            descriptionLabel.textColor = .white
            descriptionLabel.text = mediaItem.description
            
        default:
            break
        }
        displayDelegate.configureMediaMessageImageView(imageView, for: message, at: indexPath, in: messagesCollectionView)
    }
    
    /// Handle tap gesture on contentView and its subviews.
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: backgroundImageView)

        guard backgroundImageView.frame.contains(touchLocation) else {
            super.handleTapGesture(gesture)
            return
        }
        delegate?.didTapImage(in: self)
    }
    
}
