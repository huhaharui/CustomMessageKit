/*
 MIT License

 Copyright (c) 2017-2019 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit
import AVFoundation

/// A subclass of `MessageContentCell` used to display video and audio messages.
open class AudioMessageCell: MessageContentCell {

    /// The play button view to display on audio messages.
    public lazy var playButton: UIButton = {
        let playButton = UIButton(type: .custom)
        playButton.imageView?.animationDuration = 1
        let playImage = UIImage.messageKitImageWith(type: .play)
        return playButton
    }()

    /// The time duration label to display on audio messages.
    public lazy var durationLabel: UILabel = {
        let durationLabel = UILabel(frame: CGRect.zero)
        durationLabel.textAlignment = .right
        durationLabel.font = UIFont.systemFont(ofSize: 14)
        durationLabel.text = "0"
        return durationLabel
    }()

    public lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.isHidden = true
        return activityIndicatorView
    }()

    public lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.0
        return progressView
    }()
    
    // MARK: - Methods

    /// Responsible for setting up the constraints of the cell's subviews.
    open func setupConstraints() {
        playButton.constraint(equalTo: CGSize(width: 25, height: 25))
        activityIndicatorView.addConstraints(centerY: playButton.centerYAnchor, centerX: playButton.centerXAnchor)
    }

    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(playButton)
        messageContainerView.addSubview(activityIndicatorView)
        messageContainerView.addSubview(durationLabel)
        setupConstraints()
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        playButton.isSelected = false
        activityIndicatorView.stopAnimating()
        playButton.isHidden = false
        durationLabel.text = "0"
    }

    /// Handle tap gesture on contentView and its subviews.
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        // compute play button touch area, currently play button size is (25, 25) which is hardly touchable
        // add 10 px around current button frame and test the touch against this new frame
        let playButtonTouchArea = CGRect(playButton.frame.origin.x - 10.0, playButton.frame.origin.y - 10, playButton.frame.size.width + 20, playButton.frame.size.height + 20)
        let translateTouchLocation = convert(touchLocation, to: messageContainerView)
        if playButtonTouchArea.contains(translateTouchLocation) {
            delegate?.didTapPlayButton(in: self)
        } else {
            super.handleTapGesture(gesture)
        }
    }

    // MARK: - Configure Cell

    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }

        let playButtonLeftConstraint = messageContainerView.constraints.filter { $0.identifier == "left" }.first
        let durationLabelRightConstraint = messageContainerView.constraints.filter { $0.identifier == "right" }.first

        if dataSource.isFromCurrentSender(message: message) {
            playButtonLeftConstraint?.constant = 5
            durationLabelRightConstraint?.constant = -15
            playButton.addConstraints(right: messageContainerView.rightAnchor, centerY: messageContainerView.centerYAnchor, rightConstant: 5)
            durationLabel.addConstraints(right: playButton.leftAnchor, centerY: messageContainerView.centerYAnchor, rightConstant: 5)
            
            playButton.setImage(UIImage(named: "SenderVoiceNodePlaying"), for: .normal)
            playButton.imageView!.animationImages = [
                UIImage(named: "SenderVoiceNodePlaying001")!,
                UIImage(named: "SenderVoiceNodePlaying001")!,
                UIImage(named: "SenderVoiceNodePlaying003")!
            ]
        } else {
            playButtonLeftConstraint?.constant = 12
            durationLabelRightConstraint?.constant = -8
            playButton.addConstraints(left: messageContainerView.leftAnchor, centerY: messageContainerView.centerYAnchor, leftConstant: 5)
            durationLabel.addConstraints(left: playButton.rightAnchor, centerY: messageContainerView.centerYAnchor, leftConstant: 5)
   
            playButton.setImage(UIImage(named: "ReceiverVoiceNodePlaying"), for: .normal)
            playButton.imageView!.animationImages = [
                UIImage(named: "ReceiverVoiceNodePlaying001")!,
                UIImage(named: "ReceiverVoiceNodePlaying002")!,
                UIImage(named: "ReceiverVoiceNodePlaying003")!
            ]
            
        }

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }

        let tintColor = displayDelegate.audioTintColor(for: message, at: indexPath, in: messagesCollectionView)
        playButton.imageView?.tintColor = tintColor
        durationLabel.textColor = tintColor
        
        if case let .audio(audioItem) = message.kind {
            durationLabel.text = displayDelegate.audioProgressTextFormat(audioItem.duration, for: self, in: messagesCollectionView)
        }

        displayDelegate.configureAudioCell(self, message: message)
    }
}
