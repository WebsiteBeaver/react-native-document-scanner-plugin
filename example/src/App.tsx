import { useState, useEffect } from 'react';
import { Image, StyleSheet } from 'react-native';
import DocumentScanner from 'react-native-document-scanner-plugin';

export default () => {
  const [scannedImage, setScannedImage] = useState<any>();

  const scanDocument = async () => {
    // start the document scanner
    const { scannedImages } = await DocumentScanner.scanDocument();

    // check if undefined
    if (scannedImages) {
      // get back an array with scanned image file paths
      if (scannedImages.length > 0) {
        // set the img src, so we can view the first scanned image
        setScannedImage(scannedImages[0]);
      }
    }
  };

  useEffect(() => {
    // call scanDocument on load
    scanDocument();
  }, []);

  return <Image style={styles.image} source={{ uri: scannedImage }} />;
};

const styles = StyleSheet.create({
  image: { width: '100%', height: '100%' },
});
