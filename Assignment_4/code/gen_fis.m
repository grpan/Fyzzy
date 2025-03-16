%% Split - Preprocess Data
%gen_fis - Generate a fis object.

function fis = gen_fis(per_class, trnData, radius, high_dim)

if per_class == false % Class Independent
    opt = genfisOptions('SubtractiveClustering', "ClusterInfluenceRange", radius); % todo: radious chage
    fis = genfis(trnData(:,1:end-1), trnData(:,end),opt);
% elseif per_class == true % Class Dependent
else
    if ~high_dim

        %%Clustering Per Class
        [c1,sig1]=subclust(trnData(trnData(:,end)==1,:),radius);
        [c2,sig2]=subclust(trnData(trnData(:,end)==2,:),radius);
        num_rules=size(c1,1)+size(c2,1);
        
        %Build FIS From Scratch
        fis=sugfis('Name','FIS_SC');
        
        %Add Input-Output Variables
        names_in={'in1','in2','in3','in4','in5'};
        for i=1:size(trnData,2)-1
            fis=addInput(fis, [0 1], 'Name', names_in{i});
        end
        fis=addOutput(fis,[0 1],'Name','out1');
        
        %Add Input Membership Functions
        for i=1:size(trnData,2)-1
            for j=1:size(c1,1)
                fis=addMF(fis,'in' + string(i) ,'gaussmf',[sig1(i) c1(j,i)]);%, 'Name', name);
            end
            for j=1:size(c2,1)
                fis=addMF(fis,'in' + string(i) ,'gaussmf',[sig2(i) c2(j,i)]);
            end
        end
        
        %Add Output Membership Functions
        params=[zeros(1,size(c1,1)) ones(1,size(c2,1))];
        for i=1:num_rules
            fis=addMF(fis,'out1' ,'constant',params(i));
        end
        
        %Add FIS Rule Base
        ruleList=zeros(num_rules,size(trnData,2));
        for i=1:size(ruleList,1)
            ruleList(i,:)=i;
        end
        ruleList=[ruleList ones(num_rules,2)];
        fis=addrule(fis,ruleList);
    else
        classes = unique(trnData(:,end));
        num_classes = length(classes);
        num_rules=0;
        
        %Build FIS From Scratch
        fis=sugfis('Name','FIS_SC');
        
        %Add Input-Output Variables
        names_in= "in" + [1:size(trnData,2)-1];
        for i=1:size(trnData,2)-1
            fis=addInput(fis, [0 1], 'Name', names_in{i});
        end
        fis=addOutput(fis,[min(classes) max(classes)],'Name','out1');
        
        %Add Input Membership Functions
        c_sizes = zeros(1,num_classes);
        for k=1:num_classes
            [c,sig]=subclust(trnData(trnData(:,end)==classes(k),:),radius);
            num_rules = num_rules + size(c,1);
            c_sizes(k) = size(c,1);
            for i=1:size(trnData,2)-1
                for j=1:size(c,1)
                    fis=addMF(fis,'in' + string(i) ,'gaussmf',[sig(i) c(j,i)]);%, 'Name', name);
                end
            end
        end
        
        %Add Output Membership Functions
        params = repelem(classes, c_sizes);
        for i=1:num_rules
            fis=addMF(fis,'out1' ,'constant',params(i));
        end
        
        %Add FIS Rule Base
        ruleList=zeros(num_rules,size(trnData,2));
        for i=1:size(ruleList,1)
            ruleList(i,:)=i;
        end
        ruleList=[ruleList ones(num_rules,2)];
        fis=addrule(fis,ruleList);

    end
end
% else
%     disp('Not appropriate choice.');
% end


% fis.Name = fis.Name + " Trained";



end
