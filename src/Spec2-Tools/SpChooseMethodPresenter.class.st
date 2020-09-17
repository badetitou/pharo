"
I am an UI used to select a method of the system.
 
I'll display the list of packages of the system, the classes of the selected package and the methods of the selected class, the protocols of selectedClass. 

The user can configure me with an action to execute when the user does the selection. The action will take my instance as parameter to get the package/class/method/protocols selected.

###Public API and Key Messages

- `#openOnAccept:`  This method will open me in a modal and execute the block as parameter when the user accept.

###Examples

```
	(self 
		openOnAccept: [ :chooseMethodPresenter | chooseMethodPresenter selectedMethod browse ])
		withWindowDo: [ :w | w title: 'Select a method example' ]
```
 
### Internal Representation and Key Implementation Points.

Instance Variables
-	packageList:						<aListPresenter>	A list of the packages of the system.
-	classList:						<aListPresenter>	A list of the classes in the selected package.
-	methodList:						<aListPresenter>	A list of the methods in the selected class.
-	protocolList:               <aListPresenter>  A list of the protocols in the selected class. 
-	radioButtonClassSide:			<aRadioButton>		A radio button to select the class side. 
-	radioButtonInstanceSide:		<aRadioButton>		A radio button to select the instance side.

"
Class {
	#name : #SpChooseMethodPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'packageList',
		'classList',
		'methodList',
		'radioButtonInstanceSide',
		'radioButtonClassSide',
		'protocolList'
	],
	#category : #'Spec2-Tools-ChooseMethod'
}

{ #category : #specs }
SpChooseMethodPresenter class >> defaultSpec [
	^ SpPanedLayout newHorizontal
		position: 25 percent;
		add: #packageList;
		add:
			(SpPanedLayout newHorizontal
				position: 25 percent;
				add: #classList;
				add:
					(SpPanedLayout newHorizontal
						position: 40 percent;
						add: #protocolList;
						add:
							(SpBoxLayout newVertical
								add: #methodList;
								add:
									(SpBoxLayout newHorizontal
										add: #radioButtonInstanceSide;
										add: #radioButtonClassSide;
										yourself)
									withConstraints: [ :contraint | contraint height: 20 ];
								yourself);
						yourself);
				yourself);
		yourself
]

{ #category : #examples }
SpChooseMethodPresenter class >> exampleMethodChooser [
	<example>
	(self openOnAccept: [ :chooseMethodPresenter | chooseMethodPresenter selectedMethod browse ]) withWindowDo: [ :w | w title: 'Select a method example' ]
]

{ #category : #examples }
SpChooseMethodPresenter class >> exampleNavigationSystem [
	<example>
	| presenter |
	presenter := self new.
	presenter openWithSpec extent: 900 @ 400.
	^ presenter
]

{ #category : #'instance creation' }
SpChooseMethodPresenter class >> openOnAccept: aBlock [
	| instance |
	instance := self new.
	instance openModalWithSpec.
	instance withWindowDo: [ :w | w okAction: [ :dialog | aBlock cull: instance cull: dialog ] ].
	^ instance
]

{ #category : #accessing }
SpChooseMethodPresenter >> classList [
	^ classList
]

{ #category : #'initialization - actions' }
SpChooseMethodPresenter >> classListAction [
	classList
		transmitTo: methodList
		transform: [ :selectedClass | 
			selectedClass
				ifNotNil: [ self methodsFromClass: selectedClass ]
				ifNil: [ #() ] ]
		postTransmission: [ :destination | destination selectIndex: 1 ].

	classList
		transmitTo: protocolList
		transform: [ :selectedClass |
			selectedClass
				ifNotNil: [ self isInstanceSideSelected
						ifTrue:
							[ selectedClass organization allProtocols as: OrderedCollection ]
						ifFalse:
							[ selectedClass class organization allProtocols as: OrderedCollection ] ] 
					ifNil: [ #()]]
		postTransmission: [ :protcolList | 
			protocolList
				selectIndex: ((protcolList items collect: [ :each | each name ]) indexOf: '-- all --') ]
]

{ #category : #initialization }
SpChooseMethodPresenter >> connectPresenters [
	self packageListAction.
	self classListAction.
	self protocolListAction.
	self radioButtonsAction.
	packageList selectIndex: 1
]

{ #category : #'initialization - actions' }
SpChooseMethodPresenter >> fillWith: aClass [

	methodList items: aClass methods.
	^ protocolList items: (aClass protocols 
		collect: [ :eachSymbol | aClass organization protocolOrganizer protocolNamed: eachSymbol ])
]

{ #category : #initialization }
SpChooseMethodPresenter >> initializeDialogWindow: aDialog [
	super initializeDialogWindow: aDialog.
	aDialog
		initialExtent: 600 @ 400;
		title: 'Select a method';
		closeOnBackdropClick: false
]

{ #category : #initialization }
SpChooseMethodPresenter >> initializePresenters [
	packageList := self newList.
	classList := self newList.
	methodList := self newList.
	radioButtonClassSide := self newRadioButton.
	radioButtonInstanceSide := self newRadioButton.
	protocolList := self newList.
	packageList
		items: RPackageOrganizer default packages;
		display: #name;
		sortingBlock: #name ascending;
		icons: [ :item | self iconNamed: #package ].
	classList
		sortingBlock: #name ascending;
		icons: [ :item | self iconNamed: item systemIconName ].
	protocolList
		display: #name;
		sortingBlock: #name ascending.
	methodList
		sortingBlock: #name ascending;
		display: #selector.
	radioButtonClassSide label: 'class side'.
	radioButtonInstanceSide
		label: 'instance side';
		state: true.
	radioButtonInstanceSide
		associatedRadioButtons: {radioButtonClassSide}.
	self focusOrder
		add: packageList;
		add: classList;
		add: methodList
]

{ #category : #testing }
SpChooseMethodPresenter >> isInstanceSideSelected [
	^ radioButtonInstanceSide state
]

{ #category : #accessing }
SpChooseMethodPresenter >> methodList [
	^ methodList
]

{ #category : #utilities }
SpChooseMethodPresenter >> methodNamed: methodSelector [
	^ (self isInstanceSideSelected ifTrue: [ self selectedClass ] ifFalse: [ self selectedClass class ]) methodNamed: methodSelector
]

{ #category : #utilities }
SpChooseMethodPresenter >> methodsFromClass: aClass [
	^ (self isInstanceSideSelected ifTrue: [ aClass ] ifFalse: [ aClass class ]) methods asOrderedCollection
]

{ #category : #accessing }
SpChooseMethodPresenter >> packageList [
	^ packageList
]

{ #category : #'initialization - actions' }
SpChooseMethodPresenter >> packageListAction [
	packageList
		transmitTo: classList
		transform: [ :selectedPackage | 
			selectedPackage
				ifNil: [ #() ]
				ifNotNil: [ selectedPackage classes asOrderedCollection ] ]
		postTransmission: [ classList selectIndex: 1 ]
]

{ #category : #accessing }
SpChooseMethodPresenter >> protocolList [
	^ protocolList
]

{ #category : #'initialization - actions' }
SpChooseMethodPresenter >> protocolListAction [
	protocolList
		transmitTo: methodList
		transform: [ :selectedProtocol | 
			selectedProtocol
				ifNotNil: [ (selectedProtocol methodSelectors
						collect: [ :methodSelector | self methodNamed: methodSelector ])
						asOrderedCollection ]
				ifNil: [ #() ] ]
		postTransmission: [ :methodPresenter | methodPresenter selectIndex: 1 ]
]

{ #category : #accessing }
SpChooseMethodPresenter >> radioButtonClassSide [
	^ radioButtonClassSide
]

{ #category : #accessing }
SpChooseMethodPresenter >> radioButtonInstanceSide [
	^ radioButtonInstanceSide
]

{ #category : #'initialization - actions' }
SpChooseMethodPresenter >> radioButtonsAction [
	radioButtonClassSide whenActivatedDo: [ self fillWith: self selectedClass class ].
	radioButtonInstanceSide whenActivatedDo: [ self fillWith: self selectedClass ]
]

{ #category : #accessing }
SpChooseMethodPresenter >> selectedClass [
	^ classList selection selectedItem
]

{ #category : #accessing }
SpChooseMethodPresenter >> selectedMethod [
	^ methodList selectedItem
]

{ #category : #accessing }
SpChooseMethodPresenter >> selectedPackage [
	^ packageList selectedItem
]

{ #category : #accessing }
SpChooseMethodPresenter >> selectedProtocol [
	^ protocolList selection selectedItem
]