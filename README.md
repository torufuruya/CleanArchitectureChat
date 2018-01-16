# Clean Architecture Chat

This is an example of an iOS application built with the [Clean Architecture](https://8thlight.com/blog/uncle-bob/2012/08/13/the-clean-architecture.html). This application doesn't use any libraries or frameworks to make it simple and easy to understand for everyone.


## Class Structure

```sh
CleanArchitectureChat/Classes
├── Builder
├── DataStore
├── Entity
├── Presenter
├── Repository
├── UseCase
├── View
└── Wireframe

8 directories, 0 files
```

## How To Try

This application uses Twitter OAuth to get Twitter followers. If you want to try, replace OAuth [parameters](https://github.com/torufuruya/CleanArchitectureChat/blob/master/CleanArchitectureChat/Classes/DataStore/TwitterRequestManager.swift#L28-L29) with your app's one.

## Contribute

Feel free to point out my misunderstanding about the Clean Architecture and give me your great idea, it is very pleasing to me. Thanks!
