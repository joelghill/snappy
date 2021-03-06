import bb.cascades 1.2
import bb.cascades.multimedia 1.0
import "tart.js" as Tart
Page {
    id: cameraPage
    actionBarVisibility: ChromeVisibility.Hidden
    onCreationCompleted: {
        camera.open(CameraUnit.Front);
        Tart.register(cameraPage);
    }
    Container {
        background: Color.Black
        layout: DockLayout {
        }
        Camera {
            attachedObjects: [
                LayoutUpdateHandler {
                    id: layout
                },
                CameraSettings {
                    id: cameraSettings
                }
            ]
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            id: camera
            onCameraOpened: {
                // Apply some settings after the camera was opened successfully
                getSettings(cameraSettings)
                cameraSettings.focusMode = CameraFocusMode.ContinuousAuto
                cameraSettings.shootingMode = CameraShootingMode.Stabilization
                cameraSettings.captureResolution = camera.supportedCaptureResolutions(cameraSettings.cameraMode)[1]
                applySettings(cameraSettings)

                // Start the view finder as it is needed by the barcode detector
                camera.startViewfinder();
            }

            onViewfinderStarted: {
                // Setup the barcode detector with the camera object now
            }
            onPhotoCaptured: {
            }
            onPhotoSaved: {
                Tart.send('shrinkImage', {
                        image: fileName,
                        res: [ layout.layoutFrame.width, layout.layoutFrame.height ]
                    })
                var page = sendPage.createObject();
                page.imageLocation = fileName;
                nav.push(page);
            }

        }
        ImageButton {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Bottom
            minWidth: 100
            minHeight: 100
            translationY: 10
            defaultImageSource: "asset:///images/timer.amd"
            onClicked: {
                camera.capturePhoto();
                console.log("camera resolutions allowed" + camera.supportedCaptureResolutions(cameraSettings.cameraMode)[1]);

            }
        }
        ImageButton {
            horizontalAlignment: HorizontalAlignment.Right
            verticalAlignment: VerticalAlignment.Bottom
            minWidth: 100
            minHeight: 100
            translationY: 10
            defaultImageSource: "asset:///images/timer.amd"
            onClicked: {
                camera.close();
                if (camera.cameraUnit == 1) {
                    camera.open(CameraUnit.Rear);
                } else
                    camera.open(CameraUnit.Front);
            }
        }
    }
}
