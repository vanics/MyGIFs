# MyGIFs
Search, save and share your favourites GIFs.

## Features
- See Trending GIFs
- Search GIFs
- Infinite Scrolling
- Favorite GIFs saving them in your device
- Share GIFs

## Architecture and Libraries
* MVVM
* RxSwift
* Moya
* Moya-ObjectMapper
* Giphy API
* Kingfisher
* SwiftyGif

## Requirements
* iOS 10+
* Xcode 9.0+
* Swift 4.0
* CocoaPods

## Developer Notes
I starting developing this project using the MVC architecture with the idea to change to MVVM + RxSwift. This way, some architectural changes would be highlighted to myself and to who may concern.  The final branch is the master branch, the other branches may lack of some refactoring. The MVC branch has a more smoother infinite scrolling tho. I might improve the scrolling in the master later using RxDataSources  to be able to make partial changes to the tableView without the mini jump when pulling more data.

### Branchs
(1) In the master branch we have the MVVM + RxSwift + More Refactorings.

(2) In the MVC branch, we have the MVC version as the name states. Notice that it has more code than the other branches, because it's using Protocol/Delegates pattern, callback/closures, and handling the tableView and collectionView DataSource and Delegates.
Note RxSwift was already imported to the project and the FeedManager is using Moya/RxSwift but not really using its RxSwift potential.

(3) In the MVVM branch, we have an incomplete implementation of MVVM.
What is missing is bindings and refactoring of the viewCells that shouldn’t be aware of the model.
I can refactor this later. But at that point, I was a bit worried with the time constraint and decided to do the binding using RxSwift once for all.


## Screenshots
<img src="Screenshots/ss00.gif?raw=true" width="280" height="500">  <img src="Screenshots/ss01.png?raw=true" width="281" height="500">  <img src="Screenshots/ss02.png?raw=true" width="281" height="542">
<img src="Screenshots/ss03.png?raw=true" width="281" height="542">  <img src="Screenshots/ss04.png?raw=true" width="281" height="542">


## Possible Improvements / Features

- Allow User to View GIF in Full Screen
- Improve Share UI/Button
- Support other orientations?
- Hide navigation bar title on iOS 11 while scrolling down.
- Create smoother animation when expanding the cell on the Feed
- Display More Info (title, username) on the image or on new view
- Better Error Handling (What if device if out of space? What if there’s no networking?)
- Better Memory/CPU Management
- iPad Support
- Drag to move/copy (iPad Support)
- Support iOS 9
- Retrieve Data from DataCore Async
- Prefetching image (Use new iOS 11 feature supporting previous versions)
- Allow user to reorganize Favorites
- Show loading on screen bottom if it’s taking too long to dynamically load (by the infinite scrolling)
- Handle network retry/reachability
- Test other solution with more fluid scrolling
- Use lower resolution GIFs? Test.
- Implement rxSwift throttle to prevent too many requests to the API
- Accessibility?
- Test in all devices

## License
MyGifs is under MIT license. See the [LICENSE](LICENSE) for more info.
