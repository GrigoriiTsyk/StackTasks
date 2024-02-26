package grigorii.tsykarev;

import com.opencsv.CSVReader;
import com.opencsv.CSVReaderBuilder;
import com.opencsv.CSVWriter;
import com.opencsv.exceptions.CsvValidationException;

import java.io.*;
import java.util.ArrayList;
import java.util.Comparator;

public class Main {
    public static void main(String[] args) throws IOException {
            FileReader fileReader = new FileReader("src/main/resources/abonents.csv");
            CSVReader csvReader = new CSVReaderBuilder(fileReader).build();

            final double stNorm = 301.26;
            final double stCount = 1.52;

            String[] nextLine;
            String[] ans;

            ArrayList<String[]> strs = new ArrayList<>();
            ArrayList<String[]> results = new ArrayList<>();

        try {
                while ((nextLine = csvReader.readNext()) != null) {
                    strs.add(nextLine[0].split(";"));
                }

                for(int i = 1; i < strs.size(); i++){
                    ans = new String[]{"", "", "", "", "", "", "", "", ""};

                    for(int j = 0; j < 8; j++)
                        ans[j] = strs.get(i)[j];

                    if(strs.get(i)[5].equals("1")){
                        ans[8] = String.format("%.2f", stNorm);

                        results.add(ans);
                    }
                    if(strs.get(i)[5].equals("2")){
                        int prev = Integer.parseInt(strs.get(i)[6]),
                            curr = Integer.parseInt(strs.get(i)[7]);

                        double result = (curr - prev) * stCount;

                        ans[8] = String.format("%.2f", result);

                        results.add(ans);
                    }
                }

                FileWriter out = new FileWriter("src/main/resources/accruals_abonents.csv");

                CSVWriter writer = new CSVWriter(out, ';', '"', '\\', "\n");

                String[] head = new String[]{"№ строки", "Фамилия", "Улица", "№ дома",  "№ Квартиры", "Тип начисления", "Предыдущее", "Текущее", "Начислено"};

                for(int j = 0; j < head.length; j++){
                    head[j] = new String(head[j].getBytes("windows-1251"), "UTF-8");
                }

                writer.writeNext(head);

                for(int i = 0; i < results.size(); i++){
                    for(int j = 0; j < head.length; j++){
                        results.get(i)[j] = new String(results.get(i)[j].getBytes("windows-1251"), "UTF-8");
                    }

                    writer.writeNext(results.get(i));
                }

                writer.close();

            Comparator<String[]> comparator = new Comparator<String[]>() {
                @Override
                public int compare(String[] o1, String[] o2) {
                    int num1 = Integer.parseInt(o1[3]), num2 = Integer.parseInt(o2[3]);

                    return (num1 < num2) ? -1 : ((num1 == num2) ? 0 : 1);
                }
            };

                results.sort(comparator);

                for (int i = 0; i < results.size(); i++){
                    String[] outp = results.get(i);

                    System.out.println(outp[0] + " " + outp[1] + " " + outp[2] + " " + outp[3] + " " + outp[4] + " " + outp[5] + " " + outp[6] + " " +
                            outp[7] + " " + outp[8]);
                }

                out = new FileWriter("src/main/resources/accruals_houses.csv");

                writer = new CSVWriter(out, ';', '"', '\\', "\n");

                head = new String[]{"№ строки", "Улица", "№ дома", "Начислено"};

                for(int j = 0; j < head.length; j++){
                    head[j] = new String(head[j].getBytes("windows-1251"), "UTF-8");
                }

                writer.writeNext(head);

                int i = 0, currentHouseNumber, nextHouseNumber, housesCounter = 1;
                String[] currentAccrualArray = results.get(0)[8].split(",");
                String currentAccrual = currentAccrualArray[0] + "." + currentAccrualArray[1];
                double sum = Double.parseDouble(currentAccrual), nextHouseNumberAccrual = 0;

                while(i + 1 < results.size()){
                    currentHouseNumber = Integer.parseInt(results.get(i)[3]);
                    nextHouseNumber = Integer.parseInt(results.get(i + 1)[3]);

                    if(currentHouseNumber == nextHouseNumber){
                        currentAccrualArray = results.get(i + 1)[8].split(",");
                        currentAccrual = currentAccrualArray[0] + "." + currentAccrualArray[1];

                        nextHouseNumberAccrual = Double.parseDouble(currentAccrual);

                        sum += nextHouseNumberAccrual;
                    }
                    else{
                        String[] output = new String[]{"" + housesCounter, results.get(i)[2], results.get(i)[3], "" + String.format("%.2f", sum)};

                        housesCounter++;

                        writer.writeNext(output);

                        if(i + 1 < results.size()){
                            currentAccrualArray = results.get(i + 1)[8].split(",");
                            currentAccrual = currentAccrualArray[0] + "." + currentAccrualArray[1];

                            sum = Double.parseDouble(currentAccrual);
                        }
                    }

                    i++;

                    if(i + 1 == results.size()){
                        currentAccrualArray = results.get(i)[8].split(",");
                        currentAccrual = currentAccrualArray[0] + "." + currentAccrualArray[1];

                        sum += Double.parseDouble(currentAccrual);

                        String[] output = new String[]{"" + housesCounter, results.get(i)[2], results.get(i)[3], "" + String.format("%.2f", sum)};

                        writer.writeNext(output);
                    }
                }

                writer.close();
            }
            catch (CsvValidationException e){
                System.out.println(e.getMessage());
            }
    }
}