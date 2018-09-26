#import "MyProfileViewController.h"

#import "LegacyComponents.h"
#import "ASWatcher.h"
#import "TGProgressWindow.h"

#import "TGLegacyComponentsContext.h"
#import "TGTelegraph.h"
#import "DQDTelegraphManager.h"
#import "TGInterfaceManager.h"

#import "TGTimelineUploadPhotoRequestBuilder.h"
#import "TGDeleteProfilePhotoActor.h"
#import "TGTimelineItem.h"

#import "TGUserSignal.h"
#import "TGAccountSignals.h"

#import "TGActionSheet.h"
#import "TGAlertView.h"

#import "TGAccountInfoCollectionItem.h"
#import "TGCollectionMultilineInputItem.h"
#import "TGVariantCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGAppDelegate.h"
#import "TGChangePhoneNumberHelpController.h"
#import "TGUsernameController.h"
#import "TGWebSearchController.h"

#import "TGModernGalleryController.h"
#import "TGProfileUserAvatarGalleryModel.h"
#import "TGProfileUserAvatarGalleryItem.h"

#import "TGPresentation.h"
#import "MyProfileTextCell.h"
#import "MyProfileImageCell.h"
#import "TGLetteredAvatarView.h"
@interface MyProfileViewController () <ASWatcher,UITableViewDelegate,UITableViewDataSource>
{
	int32_t _uid;
	NSString *_initialAbout;
	
	UIBarButtonItem *_doneItem;
	
	id<SDisposable> _updatedCachedDataDisposable;
	id<SDisposable> _currentAboutDisposable;
	SMetaDisposable *_updateAboutDisposable;
	
	TGAccountInfoCollectionItem *_profileDataItem;
	
	TGCollectionMenuSection *_aboutSection;
	TGCollectionMultilineInputItem *_inputItem;
	
	TGVariantCollectionItem *_usernameItem;
	TGVariantCollectionItem *_phoneNumberItem;
	
	TGMediaAvatarMenuMixin *_avatarMixin;
//	TGLetteredAvatarView *_avatarView;
}

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, strong) TGProgressWindow *progressWindow;
@property (nonatomic, strong) UITableView *mainTab;
@end

@implementation MyProfileViewController

- (instancetype)init
{
	self = [super init];
	if (self != nil)
	{
		_actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
		
		[ActionStageInstance() watchForPaths:@[
											   @"/tg/userdatachanges",
											   @"/tg/userpresencechanges",
											   ] watcher:self];
		
		_uid = TGTelegraphInstance.clientUserId;
		self.title = TGLocalized(@"EditProfile.Title");
		_doneItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
		[self setRightBarButtonItem:_doneItem];
		
		TGUser *user = [TGDatabaseInstance() loadUser:_uid];
		
		_profileDataItem = [[TGAccountInfoCollectionItem alloc] init];
		[_profileDataItem setUser:user animated:false];
//		_profileDataItem.showCameraIcon = true;
		_profileDataItem.disableAvatarPlaceholder = true;
		[_profileDataItem setEditing:true animated:false];
		_profileDataItem.interfaceHandle = _actionHandle;
		
//		TGCommentCollectionItem *commentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"EditProfile.NameAndPhotoHelp")];
//		commentItem.topInset = 1.0f;
		
		TGCollectionMenuSection *topSection = [[TGCollectionMenuSection alloc] initWithItems:@[_profileDataItem]];
//		[self.menuSections addSection:topSection];
		
		_inputItem = [[TGCollectionMultilineInputItem alloc] init];
		_inputItem.maxLength = 70;
		_inputItem.disallowNewLines = true;
		_inputItem.placeholder = TGLocalized(@"UserInfo.About.Placeholder");
		_inputItem.showRemainingCount = true;
		_inputItem.returnKeyType = UIReturnKeyDone;
		__weak MyProfileViewController *weakSelf = self;
		_inputItem.heightChanged = ^ {
			__strong MyProfileViewController *strongSelf = weakSelf;
			if (strongSelf != nil) {
				[strongSelf.collectionLayout invalidateLayout];
				[strongSelf.collectionView layoutSubviews];
			}
		};
		_inputItem.returned = ^ {
			__strong MyProfileViewController *strongSelf = weakSelf;
			if (strongSelf != nil) {
				[strongSelf donePressed];
			}
		};
		
//		commentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Settings.About.Help")];
//		commentItem.topInset = 1.0f;
		
		_aboutSection = [[TGCollectionMenuSection alloc] initWithItems:@[_inputItem]];
//		[self.menuSections addSection:_aboutSection];
		
		_usernameItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.Username") action:@selector(usernamePressed)];
		_phoneNumberItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.PhoneNumber") action:@selector(phoneNumberPressed)];
		
		NSString *username = user.userName.length == 0 ? TGLocalized(@"Settings.UsernameEmpty") : [[NSString alloc] initWithFormat:@"@%@", user.userName];
		_usernameItem.variant = username;
		
		NSString *phoneNumber = user.phoneNumber.length == 0 ? @"" : [TGPhoneUtils formatPhone:user.phoneNumber forceInternational:true];
		_phoneNumberItem.variant = phoneNumber;
		
		TGCollectionMenuSection *credentialsSection = [[TGCollectionMenuSection alloc] initWithItems:@[_phoneNumberItem, _usernameItem]];
//		[self.menuSections addSection:credentialsSection];
		
		
		//隐藏原来的显示内容，新增自己的设计样式
		self.mainTab = [[UITableView alloc]initWithFrame:self.collectionView.frame];
		self.mainTab.translatesAutoresizingMaskIntoConstraints = NO;
		self.mainTab.backgroundColor = [[UIColor alloc] initWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
		[self.view addSubview:self.mainTab];
		
		;
		[self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.mainTab attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
									[NSLayoutConstraint constraintWithItem:self.mainTab attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeRight multiplier:1 constant:0],
									[NSLayoutConstraint constraintWithItem:self.mainTab attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
									[NSLayoutConstraint constraintWithItem:self.mainTab attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]]];
		
		[self.mainTab registerNib:[UINib nibWithNibName:@"MyProfileTextCell" bundle:nil] forCellReuseIdentifier:@"MyProfileTextCell"];
		[self.mainTab registerNib:[UINib nibWithNibName:@"MyProfileImageCell" bundle:nil] forCellReuseIdentifier:@"MyProfileImageCell"];
		self.mainTab.delegate = self;
		self.mainTab.dataSource = self;
		self.mainTab.estimatedRowHeight = 50;
		self.mainTab.separatorStyle = UITableViewCellSeparatorStyleNone;
		
//		_avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width - 45 - 18, 64 + 15 + 15, 41, 41)];
//		[_avatarView setSingleFontSize:28.0f doubleFontSize:28.0f useBoldFont:false];
//		_avatarView.fadeTransition = true;
//		_avatarView.userInteractionEnabled = true;
//
//		[_avatarView loadImage:user.photoUrlSmall filter:user.photoUrlSmall placeholder:nil];
//		[self.mainTab addSubview:_avatarView];
	}
	return self;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewAutomaticDimension;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
		MyProfileImageCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MyProfileImageCell"];
		cell.titleLB.text = @"PROFILE PHOTO";
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell.avartaView loadImage:[TGDatabaseInstance() loadUser:_uid].photoUrlSmall filter:[TGDatabaseInstance() loadUser:_uid].photoUrlSmall placeholder:nil];
		return cell;
	}
	
	MyProfileTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyProfileTextCell"];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	if (indexPath.section == 1){
		cell.titleLabel.text = @"NAME";
		cell.subTitleLB.text = _usernameItem.variant;
	}else if (indexPath.section == 2) {
		cell.titleLabel.text = @"PHONE NUMBER";
		cell.subTitleLB.text = _phoneNumberItem.variant;
		cell.rightImageV.hidden = YES;
		cell.subTitleRightContent.constant = -18;
	}else {
		cell.titleLabel.text = @"BIO";
		cell.subTitleLB.text = _inputItem.text;
	}
	return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 15;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [UIView new];
	view.backgroundColor = [[UIColor alloc] initWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
	view.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 15);
	return view;
}

- (void)dealloc {
	[_updateAboutDisposable dispose];
	[_currentAboutDisposable dispose];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_updatedCachedDataDisposable = [[TGUserSignal updatedUserCachedDataWithUserId:TGTelegraphInstance.clientUserId] startWithNext:nil];
	
	__weak MyProfileViewController *weakSelf = self;
	_currentAboutDisposable = [[[[[[TGDatabaseInstance() userCachedData:TGTelegraphInstance.clientUserId] map:^NSString *(TGCachedUserData *data)
								   {
									   return data.about ?: @"";
								   }] ignoreRepeated] take:2] deliverOn:[SQueue mainQueue]] startWithNext:^(NSString *about)
							   {
								   __strong MyProfileViewController *strongSelf = weakSelf;
								   if (strongSelf != nil) {
									   strongSelf->_initialAbout = about;
									   
									   [strongSelf->_inputItem setText:about];
//									   [strongSelf.collectionLayout invalidateLayout];
//									   [strongSelf.collectionView layoutSubviews];
									   [strongSelf.mainTab reloadData];
								   }
							   }];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[ActionStageInstance() dispatchOnStageQueue:^
	 {
		 NSArray *uploadActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/timeline/@/uploadPhoto/@" prefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/uploadPhoto/", _uid] watcher:self];
		 NSArray *deleteActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/timeline/@/deleteAvatar/@" prefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/deleteAvatar/", _uid] watcher:self];
		 if (uploadActions.count != 0)
		 {
			 TGTimelineUploadPhotoRequestBuilder *actor = (TGTimelineUploadPhotoRequestBuilder *)[ActionStageInstance() executingActorWithPath:uploadActions.lastObject];
			 if (actor != nil)
			 {
				 TGDispatchOnMainThread(^
										{
											[_profileDataItem setUpdatingAvatar:actor.currentPhoto hasUpdatingAvatar:true];
										});
			 }
		 }
		 else if (deleteActions.count != 0)
		 {
			 TGDeleteProfilePhotoActor *actor = (TGDeleteProfilePhotoActor *)[ActionStageInstance() executingActorWithPath:deleteActions.lastObject];
			 if (actor != nil)
			 {
				 TGDispatchOnMainThread(^
										{
											[_profileDataItem setUpdatingAvatar:nil hasUpdatingAvatar:true];
										});
			 }
		 }
	 }];
}

- (void)donePressed
{
	TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
	[progressWindow show:true];
	
	TGUser *user = [TGDatabaseInstance() loadUser:_uid];
	if (!TGStringCompare(user.firstName, [_profileDataItem editingFirstName]) || !TGStringCompare(user.lastName, [_profileDataItem editingLastName]))
	{
		[_profileDataItem setUpdatingFirstName:[_profileDataItem editingFirstName] updatingLastName:[_profileDataItem editingLastName]];
		
		static int actionId = 0;
		NSString *action = [[NSString alloc] initWithFormat:@"/tg/changeUserName/(%d)", actionId++];
		NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:[_profileDataItem editingFirstName], @"firstName", [_profileDataItem editingLastName], @"lastName", nil];
		[ActionStageInstance() requestActor:action options:options flags:0 watcher:self];
	}
	
	NSString *text = [_inputItem.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (![text isEqualToString:_initialAbout])
	{
		[_updateAboutDisposable setDisposable:[[[[TGAccountSignals updateAbout:text] deliverOn:[SQueue mainQueue]] onDispose:^
												{
													[progressWindow dismiss:true];
												}] startWithNext:nil error:^(__unused id error) {
													[[[TGAlertView alloc] initWithTitle:TGLocalized(@"Login.UnknownError") message:nil cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
												} completed:^{
												}]];
	}
	
	[self.navigationController popViewControllerAnimated:true];
}

- (void)viewProfilePhoto
{
	TGUser *user = [TGDatabaseInstance() loadUser:_uid];
	
	if ([_profileDataItem hasUpdatingAvatar])
	{
		TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:nil actions:@[
																						[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhotoStop") action:@"stop" type:TGActionSheetActionTypeDestructive],
																						[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel],
																						] actionBlock:^(id target, NSString *action)
									  {
										  if ([action isEqualToString:@"stop"])
										  {
											  [(MyProfileViewController *)target _commitCancelAvatarUpdate];
										  }
									  } target:self];
		[actionSheet showInView:self.view];
	}
	else
	{
		TGRemoteImageView *avatarView = [_profileDataItem visibleAvatarView];
		
		if (user != nil && user.photoUrlBig != nil && avatarView.currentImage != nil)
		{
			TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] initWithContext:[TGLegacyComponentsContext shared]];
			
			TGProfileUserAvatarGalleryModel *model = [[TGProfileUserAvatarGalleryModel alloc] initWithCurrentAvatarLegacyThumbnailImageUri:user.photoUrlSmall currentAvatarLegacyImageUri:user.photoUrlBig currentAvatarImageSize:CGSizeMake(640.0f, 640.0f)];
			
			__weak MyProfileViewController *weakSelf = self;
			model.deleteCurrentAvatar = ^
			{
				__strong MyProfileViewController *strongSelf = weakSelf;
				[strongSelf _commitDeleteAvatar];
			};
			
			modernGallery.model = model;
			
			modernGallery.itemFocused = ^(id<TGModernGalleryItem> item)
			{
				__strong MyProfileViewController *strongSelf = weakSelf;
				if (strongSelf != nil)
				{
					if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
					{
						if (((TGUserAvatarGalleryItem *)item).isCurrent)
						{
							[strongSelf->_profileDataItem setAvatarHidden:true animated:false];
						}
						else
							[strongSelf->_profileDataItem setAvatarHidden:false animated:false];
					}
				}
			};
			
			modernGallery.beginTransitionIn = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
			{
				__strong MyProfileViewController *strongSelf = weakSelf;
				if (strongSelf != nil)
				{
					if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
					{
						if (((TGUserAvatarGalleryItem *)item).isCurrent)
						{
							return strongSelf->_profileDataItem.visibleAvatarView;
						}
					}
				}
				
				return nil;
			};
			
			modernGallery.beginTransitionOut = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
			{
				__strong MyProfileViewController *strongSelf = weakSelf;
				if (strongSelf != nil)
				{
					if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
					{
						if (((TGUserAvatarGalleryItem *)item).isCurrent)
						{
							return strongSelf->_profileDataItem.visibleAvatarView;
						}
					}
				}
				
				return nil;
			};
			
			modernGallery.completedTransitionOut = ^
			{
				__strong MyProfileViewController *strongSelf = weakSelf;
				if (strongSelf != nil)
				{
					[strongSelf->_profileDataItem setAvatarHidden:false animated:true];
				}
			};
			
			TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithManager:[[TGLegacyComponentsContext shared] makeOverlayWindowManager] parentController:self contentController:modernGallery];
			controllerWindow.hidden = false;
		}
	}
}

- (void)setProfilePhotoPressed
{
	TGUser *user = [TGDatabaseInstance() loadUser:_uid];
	
	__weak MyProfileViewController *weakSelf = self;
	//Avazu 20180606 注释
	_avatarMixin = [[TGMediaAvatarMenuMixin alloc] initWithContext:[TGLegacyComponentsContext shared] parentController:self hasDeleteButton:true hasViewButton:user.photoUrlSmall.length > 0 personalPhoto:true saveEditedPhotos:TGAppDelegateInstance.saveEditedPhotos saveCapturedMedia:TGAppDelegateInstance.saveCapturedMedia];
	_avatarMixin.didFinishWithImage = ^(UIImage *image)
	{
		__strong MyProfileViewController *strongSelf = weakSelf;
		if (strongSelf == nil)
			return;
		
		[strongSelf _updateProfileImage:image];
		strongSelf->_avatarMixin = nil;
	};
	_avatarMixin.didFinishWithDelete = ^
	{
		__strong MyProfileViewController *strongSelf = weakSelf;
		if (strongSelf == nil)
			return;
		
		[strongSelf _commitDeleteAvatar];
		strongSelf->_avatarMixin = nil;
	};
	_avatarMixin.didFinishWithView = ^
	{
		__strong MyProfileViewController *strongSelf = weakSelf;
		if (strongSelf == nil)
			return;
		
		[strongSelf viewProfilePhoto];
		strongSelf->_avatarMixin = nil;
	};
	_avatarMixin.didDismiss = ^
	{
		__strong MyProfileViewController *strongSelf = weakSelf;
		if (strongSelf == nil)
			return;
		
		strongSelf->_avatarMixin = nil;
	};
	_avatarMixin.requestSearchController = ^TGViewController *(TGMediaAssetsController *assetsController) {
		TGWebSearchController *searchController = [[TGWebSearchController alloc] initWithContext:[TGLegacyComponentsContext shared] forAvatarSelection:true embedded:true allowGrouping:false];
		
		__weak TGMediaAssetsController *weakAssetsController = assetsController;
		__weak TGWebSearchController *weakController = searchController;
		searchController.avatarCompletionBlock = ^(UIImage *image) {
			__strong TGMediaAssetsController *strongAssetsController = weakAssetsController;
			if (strongAssetsController.avatarCompletionBlock == nil)
				return;
			
			strongAssetsController.avatarCompletionBlock(image);
		};
		searchController.dismiss = ^
		{
			__strong TGWebSearchController *strongController = weakController;
			if (strongController == nil)
				return;
			
			[strongController dismissEmbeddedAnimated:true];
		};
		searchController.parentNavigationController = assetsController;
		[searchController presentEmbeddedInController:assetsController animated:true];
		
		return searchController;
	};
	[_avatarMixin present];
}

- (void)phoneNumberPressed
{
	TGChangePhoneNumberHelpController *phoneNumberController = [[TGChangePhoneNumberHelpController alloc] init];
	
	TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[phoneNumberController]];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		navigationController.restrictLandscape = true;
	else
	{
		navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
		navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	}
	
	[self presentViewController:navigationController animated:true completion:nil];
}

- (void)usernamePressed
{
	TGUsernameController *usernameController = [[TGUsernameController alloc] init];
	
	TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[usernameController]];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		navigationController.restrictLandscape = false;
	else
	{
		navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
		navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	}
	
	[self presentViewController:navigationController animated:true completion:nil];
}

- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
{
	if ([action isEqualToString:@"avatarTapped"])
	{
		if ([_profileDataItem hasUpdatingAvatar])
		{
			TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:nil actions:@[
																							[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhotoStop") action:@"stop" type:TGActionSheetActionTypeDestructive],
																							[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel],
																							] actionBlock:^(id target, NSString *action)
										  {
											  if ([action isEqualToString:@"stop"])
											  {
												  [(MyProfileViewController *)target _commitCancelAvatarUpdate];
											  }
										  } target:self];
			[actionSheet showInView:self.view];
		}
		else
		{
			[self setProfilePhotoPressed];
		}
	}
	else if ([action isEqualToString:@"deleteAvatar"])
	{
		[self _commitDeleteAvatar];
	}
	else if ([action isEqualToString:@"editingNameChanged"])
	{
		_doneItem.enabled = [_profileDataItem editingFirstName].length != 0;
	}
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)__unused resource arguments:(id)__unused arguments
{
	if ([path isEqualToString:@"/tg/loggedOut"])
	{
		TGDispatchOnMainThread(^{
			[_progressWindow dismiss:true];
			_progressWindow = nil;
		});
	}
	else if ([path isEqualToString:@"/tg/userdatachanges"] || [path isEqualToString:@"/tg/userpresencechanges"])
	{
		NSArray *users = ((SGraphObjectNode *)resource).object;
		
		for (TGUser *user in users)
		{
			if (user.uid == _uid)
			{
				TGDispatchOnMainThread(^
									   {
										   [_profileDataItem setUser:user animated:true];
										   [_usernameItem setVariant:user.userName.length == 0 ? TGLocalized(@"Settings.UsernameEmpty") : [[NSString alloc] initWithFormat:@"@%@", user.userName]];
										   [_phoneNumberItem setVariant:user.phoneNumber.length == 0 ? @"" : [TGPhoneUtils formatPhone:user.phoneNumber forceInternational:true]];
									   });
			}
		}
	}
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
	if ([path hasPrefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/uploadPhoto", _uid]] || [path hasPrefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/deleteAvatar/", _uid]])
	{
		TGImageInfo *imageInfo = ((TGTimelineItem *)((SGraphObjectNode *)result).object).imageInfo;
		
		TGDispatchOnMainThread(^
							   {
								   if (status == ASStatusSuccess)
								   {
									   NSString *photoUrl = [imageInfo closestImageUrlWithSize:CGSizeMake(160, 160) resultingSize:NULL];
									   
									   if (photoUrl != nil)
										   [_profileDataItem copyUpdatingAvatarToCacheWithUri:photoUrl];
									   
									   [_profileDataItem resetUpdatingAvatar:photoUrl];
								   }
								   else
								   {
									   [_profileDataItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
									   
									   TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Login.UnknownError") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
									   [alertView show];
								   }
							   });
	}
}

- (void)_updateProfileImage:(UIImage *)image
{
	if (image == nil)
		return;
	
	if (MIN(image.size.width, image.size.height) < 160.0f)
		image = TGScaleImageToPixelSize(image, CGSizeMake(160, 160));
	
	NSData *imageData = UIImageJPEGRepresentation(image, 0.6f);
	if (imageData == nil)
		return;
	
	[(UIView *)[_profileDataItem visibleAvatarView] setHidden:false];
	
	TGImageProcessor filter = [TGRemoteImageView imageProcessorForName:@"circle:64x64"];
	UIImage *avatarImage = filter(image);
	
	[_profileDataItem setUpdatingAvatar:avatarImage hasUpdatingAvatar:true];
	
	NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
	
	uint8_t fileId[32];
	arc4random_buf(&fileId, 32);
	
	NSMutableString *filePath = [[NSMutableString alloc] init];
	for (int i = 0; i < 32; i++)
	{
		[filePath appendFormat:@"%02x", fileId[i]];
	}
	
	NSString *tmpImagesPath = [[DQDTelegraphManager dqd_documentsPath] stringByAppendingPathComponent:@"upload"];
	static NSFileManager *fileManager = nil;
	if (fileManager == nil)
		fileManager = [[NSFileManager alloc] init];
	NSError *error = nil;
	[fileManager createDirectoryAtPath:tmpImagesPath withIntermediateDirectories:true attributes:nil error:&error];
	NSString *absoluteFilePath = [tmpImagesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bin", filePath]];
	[imageData writeToFile:absoluteFilePath atomically:true];
	
	[options setObject:filePath forKey:@"originalFileUrl"];
	
	[options setObject:avatarImage forKey:@"currentPhoto"];
	
	[ActionStageInstance() dispatchOnStageQueue:^
	 {
		 NSString *action = [[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/uploadPhoto/(%@)", _uid, filePath];
		 [ActionStageInstance() requestActor:action options:options watcher:self];
		 [ActionStageInstance() requestActor:action options:options watcher:TGTelegraphInstance];
	 }];
}

- (void)_commitCancelAvatarUpdate
{
	[_profileDataItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
	
	[ActionStageInstance() dispatchOnStageQueue:^
	 {
		 NSArray *deleteActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/timeline/@/deleteAvatar/@" prefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")", _uid] watcher:self];
		 NSArray *uploadActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/timeline/@/uploadPhoto/@" prefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")", _uid] watcher:self];
		 
		 for (NSString *action in deleteActions)
		 {
			 [ActionStageInstance() removeAllWatchersFromPath:action];
		 }
		 
		 for (NSString *action in uploadActions)
		 {
			 [ActionStageInstance() removeAllWatchersFromPath:action];
		 }
	 }];
}

- (void)_commitDeleteAvatar
{
	[_profileDataItem setHasUpdatingAvatar:true];
	
	static int actionId = 0;
	
	NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:_uid], @"uid", nil];
	NSString *action = [[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/deleteAvatar/(%d)", _uid, actionId++];
	[ActionStageInstance() requestActor:action options:options watcher:self];
	[ActionStageInstance() requestActor:action options:options watcher:TGTelegraphInstance];
}

- (void)_resetCollectionView {
	[super _resetCollectionView];
	
	if (iosMajorVersion() >= 7) {
		self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
	}
}


@end
