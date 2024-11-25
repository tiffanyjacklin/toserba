import { jsPDF } from 'jspdf';
import html2canvas from 'html2canvas';

/**
 * Fetches content from a URL, captures it as an HD image, and generates a PDF scaled to fit the A4 page size.
 * Instead of downloading the PDF, it opens the PDF in a new browser tab.
 *
 * @param {string} url - The URL of the content to be rendered in the PDF.
 * @param {string} filename - A reference name for the PDF file.
 */
export default function viewHTMLAsPDFFromURL(url, filename = 'preview') {
    // Create an iframe to load the external content
    const iframe = document.createElement('iframe');
    iframe.style.display = 'block';
    document.body.appendChild(iframe);

    iframe.onload = () => {
        const iframeDocument = iframe.contentDocument || iframe.contentWindow.document;

        // Target the entire iframe document or a specific selector
        const contentToCapture = iframeDocument.querySelector('#printTarget'); 

        if (!contentToCapture) {
            console.error("Failed to capture content from the URL.");
            document.body.removeChild(iframe);
            return;
        }

        // Use html2canvas to capture the content as an image
        html2canvas(contentToCapture, {
            scale: 3, // Increase scale to 2x (HD resolution)
        }).then((canvas) => {
            // Create a new jsPDF instance for A4 paper size
            const pdf = new jsPDF('p', 'mm', 'a4');  // Portrait, A4 size

            const pageWidth = pdf.internal.pageSize.getWidth();  // A4 page width in mm
            const pageHeight = pdf.internal.pageSize.getHeight();  // A4 page height in mm

            const imgData = canvas.toDataURL('image/png'); // Convert canvas to image data

            // Calculate the scaling factor to fit the A4 page
            const scale = Math.min(pageWidth / canvas.width, pageHeight / canvas.height);
            const imgWidth = canvas.width * scale;
            const imgHeight = canvas.height * scale;

            // Add the image to the PDF at the scaled size
            pdf.addImage(imgData, 'PNG', 0, 0, imgWidth, imgHeight);

            // Create a blob of the PDF data
            const pdfBlob = pdf.output('blob');

            // Create an object URL for the PDF blob
            const pdfURL = URL.createObjectURL(pdfBlob);

            // Open the PDF in a new browser tab
            window.open(pdfURL, '_blank');

            // Clean up by removing the iframe
            document.body.removeChild(iframe);
        }).catch((error) => {
            console.error("Failed to capture content as image:", error);
            document.body.removeChild(iframe);
        });
    };

    iframe.src = url; // Load the URL into the iframe
}
