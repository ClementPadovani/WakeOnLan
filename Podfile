# Uncomment this line to define a global platform for your project

platform :osx, '10.9'

xcodeproj 'WakeOnLan'

target 'WakeOnLan' do

pod 'Fabric-OSX', :configurations => ['Release']

pod 'Crashlytics-OSX', :configurations => ['Release']

pod 'SNRFetchedResultsController'

end

target 'UDPWOLTest', :exclusive => true do

pod 'CocoaAsyncSocket'

end

