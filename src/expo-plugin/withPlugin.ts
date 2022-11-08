// Based on https://github.com/mrousavy/react-native-vision-camera/blob/main/src/expo-plugin/withVisionCamera.ts
import {
  withPlugins,
  AndroidConfig,
  ConfigPlugin,
  createRunOncePlugin,
} from '@expo/config-plugins';

// eslint-disable-next-line @typescript-eslint/no-var-requires, @typescript-eslint/no-unsafe-assignment
const pkg = require('../../../package.json');

const CAMERA_USAGE = 'Allow $(PRODUCT_NAME) to access your camera';

type Props = {
  cameraPermissionText?: string;
};

const withPlugin: ConfigPlugin<Props> = (config, props = {}) => {
  if (config.ios == null) config.ios = {};
  if (config.ios.infoPlist == null) config.ios.infoPlist = {};
  config.ios.infoPlist.NSCameraUsageDescription =
    props.cameraPermissionText ??
    (config.ios.infoPlist.NSCameraUsageDescription as string | undefined) ??
    CAMERA_USAGE;
  const androidPermissions = ['android.permission.CAMERA'];

  return withPlugins(config, [
    [AndroidConfig.Permissions.withPermissions, androidPermissions],
  ]);
};

export default createRunOncePlugin(withPlugin, pkg.name, pkg.version);
