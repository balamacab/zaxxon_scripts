function result = gtk(in,out,message)
        fputs(in,message);
        fflush(in);
        result = "";
        while 1
                s = fgets(out);
                if s == -1
                        sleep(0.05);
                        fclear(out);
                elseif ischar(s)
                        result = s;
                        break;
                end
        end
end
