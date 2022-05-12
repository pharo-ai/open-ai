Class {
	#name : #BaselineOfOpenAI,
	#superclass : #BaselineOf,
	#category : #BaselineOfOpenAI
}

{ #category : #baselines }
BaselineOfOpenAI >> baseline: spec [

	<baseline>
	spec for: #pharo do: [ 
		self
			setUpDependencies: spec;
			setUpPackages: spec.
		spec
			group: 'CI' with: 'Tests';
			group: 'Development' with: #( 'Tests' 'Examples' )
		]
]

{ #category : #accessing }
BaselineOfOpenAI >> projectClass [

	^ MetacelloCypressBaselineProject
]

{ #category : #accessing }
BaselineOfOpenAI >> setUpDependencies: spec [

	spec
		baseline: 'Superluminal' with: [ spec repository: 'github://ba-st/Superluminal:v4' ];
		project: 'Superluminal-Deployment' copyFrom: 'Superluminal' with: [ spec loads: 'Deployment' ];
		project: 'Superluminal-SUnit'
		copyFrom: 'Superluminal'
		with: [ spec loads: 'Dependent-SUnit-Extensions' ]
]

{ #category : #accessing }
BaselineOfOpenAI >> setUpDeploymentPackages: spec [

	spec
		package: 'Open-AI-Model' with: [ spec requires: #( 'Superluminal-Deployment' ) ];
		group: 'Core' with: #( 'Open-AI-Model' );
		group: 'Deployment' with: #( 'Core' )
]

{ #category : #accessing }
BaselineOfOpenAI >> setUpPackages: spec [

	self setUpDeploymentPackages: spec.
	spec
		package: 'Open-AI-Model-Tests' with: [ spec requires: #( 'Open-AI-Model' 'Superluminal-SUnit' ) ];
		group: 'Tests' with: #( 'OpenAI-Model-Tests' );
		package: 'Open-AI-Examples' with: [ spec requires: #( 'Deployment' 'Superluminal-Deployment' ) ];
		group: 'Examples' with: #( 'Open-AI-Examples' )
]
