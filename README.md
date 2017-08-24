# arkit-occlusion-demo
Bjarne Lundgren / bjarne@sent.com / [@bjarnel](https://twitter.com/bjarnel)

This ARKit+SceneKit project shows how to "track" vertical planes (relative to horizontal planes anyway), and how to occlude objects with real world geometry. There is no cheating or magic in this app, this stuff is not really possible with (the current version of) ARKit out of the box - basically you need to tell the app about where the walls/real world geometry is. THEN the app sets up the appropriate masking planes and physics bodies. This is then used to bounce balls of the walls as well as occluding them.

This requires, Xcode 9, iOS 11 and a relatively recent iOS device.

You can pretty much do want you want with the code, but please provide attribution, also if you use it to create a video.

Unedited gameplay video (youtube):

[![ARKit occlusion demo original video](https://raw.githubusercontent.com/bjarnel/arkit-occlusion/master/img/youtube_vid.png)](https://youtu.be/akCCwPeHF9k "ARKit occlusion demo original video")

Screenshots (click for bigger version):

[![First mapping the real world geometry](https://raw.githubusercontent.com/bjarnel/arkit-occlusion/master/img/screenshot-mapping-thumbnail.png)](https://raw.githubusercontent.com/bjarnel/arkit-occlusion/master/img/screenshot-mapping.png "First mapping the real world geometry")
[![Throwing beachballs, that bounces of the walls and are occluded by other walls](https://raw.githubusercontent.com/bjarnel/arkit-occlusion/master/img/screenshot-occlusion-thumbnail.png)](https://raw.githubusercontent.com/bjarnel/arkit-occlusion/master/img/screenshot-occlusion.png "Throwing beachballs, that bounces of the walls and are occluded by other walls")


License
=======

Copyright 2017 Bjarne Lundgren

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
