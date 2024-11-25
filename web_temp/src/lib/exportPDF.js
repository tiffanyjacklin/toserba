
import { jsPDF } from 'jspdf';
import html2canvas from 'html2canvas';

export default function exportToPDF(url, filename, width) {
    const urlToExport = url; 

    const iframe = document.createElement('iframe');
     iframe.style.display = 'block';
     document.body.appendChild(iframe);

     iframe.onload = () => {
    //    console.log(iframe.contentDocument.body.innerHTML);
         const contentToCapture = iframe.contentDocument.querySelector('#printTarget'); 

         if (!contentToCapture) {
             console.error("Content to capture not found.");
             document.body.removeChild(iframe);
             return;
         }

         html2canvas(contentToCapture).then((canvas) => {
             document.body.appendChild(canvas);

             const imgData = canvas.toDataURL('image/png');

             if (!imgData || imgData === 'data:,') {
                 console.error("Canvas data is invalid or corrupt.");
                 document.body.removeChild(canvas);
                 document.body.removeChild(iframe);
                 return;
             }

             const pdf = new jsPDF();
             const imgWidth = width; 
             const imgHeight = (canvas.height * imgWidth) / canvas.width;
             let heightLeft = imgHeight;

             let position = 0;

             pdf.addImage(imgData, 'PNG', 10, position, imgWidth, imgHeight);
             heightLeft -= pdf.internal.pageSize.height;

             while (heightLeft >= 0) {
                 position = heightLeft - imgHeight;
                 pdf.addPage();
                 pdf.addImage(imgData, 'PNG', 10, position, imgWidth, imgHeight);
                 heightLeft -= pdf.internal.pageSize.height;
             }

             pdf.save(filename+`.pdf`);

             document.body.removeChild(canvas);
             document.body.removeChild(iframe);
         }).catch(err => {
             console.error("Error capturing content:", err);
             document.body.removeChild(iframe);
         });
     };

     iframe.src = urlToExport;
 }

 