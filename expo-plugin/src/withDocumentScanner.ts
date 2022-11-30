import {
  ConfigPlugin,
  createRunOncePlugin,
  withInfoPlist,
} from '@expo/config-plugins';

const pkg = require('react-native-document-scanner-plugin/package.json');

const CAMERA_USAGE = 'Allow $(PRODUCT_NAME) to access your camera';

const withDocumentScanner: ConfigPlugin<
  {
    cameraPermission?: string;
  } | void
> = (config, { cameraPermission } = {}) => {
  config = withInfoPlist(config, (config) => {
    config.modResults.NSCameraUsageDescription =
      cameraPermission ||
      config.modResults.NSCameraUsageDescription ||
      CAMERA_USAGE;

    return config;
  });

  return config;
};

export default createRunOncePlugin(withDocumentScanner, pkg.name, pkg.version);
