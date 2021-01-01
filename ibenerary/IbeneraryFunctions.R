# Set the colors!:
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
colorLevels <- c("Transport", "Hotel", "Activity", "Food")
colorValues <- c(Transport = cbPalette[2], Hotel = cbPalette[4], Activity = cbPalette[6], Food = cbPalette[7])

###############################
## splitMultidayEntries ##
###############################

splitMultidayEntries <- function(PlotDF){
        
        Indexes <- which(PlotDF$endDate > PlotDF$startDate)
        DFAll <- data.frame()
        for(i in Indexes){
                multiDayEntry <- PlotDF[i,]
                # Dates <- seq.Date(as.Date(multiDayEntry$startDate), as.Date(multiDayEntry$endDate), by = "day") # gave tz problems, always changing to UTC therefore replaced by
                #Dates <- seq(ymd(multiDayEntry$startDate, tz = "CET"), ymd(multiDayEntry$endDate, tz = "CET"), by = 'days')
                # Dates <- seq(lubridate::parse_date_time(format(multiDayEntry$startDate, "%Y-%m-%d"), orders = "ymd", tz = "CET"), lubridate::parse_date_time(format(multiDayEntry$endDate, "%Y-%m-%d"), orders = "ymd", tz = "CET"), by = "days")
                Dates <- seq(date(multiDayEntry$startDate), date(multiDayEntry$endDate), by = 'days')
                DF <- multiDayEntry[rep(1, length(Dates)),]
                DF$startDate <- ymd(Dates, tz = "CET")
                #DF$endDate[1:(nrow(DF)-1)] <- Dates[1:(nrow(DF)-1)]+days(1)
                DF$endDate[1:(nrow(DF)-1)] <- ymd(Dates[1:(nrow(DF)-1)]+1, tz = "CET")
                DF$Start[2:nrow(DF)] <- update(ymd(DF$startDate[2:nrow(DF)], tz = "CET"), hour = 0, minute = 0)
                DF$End[1:(nrow(DF)-1)] <- update(ymd(DF$endDate[1:(nrow(DF)-1)], tz = "CET"), hour = 0, minute = 0)
                DF$Duration <- as.numeric(as.duration(DF$End-DF$Start), "minutes")
                # NB: Might cause trouble when there are durations < 5 min, i.e. when second date ended at 00?
                DFAll <- rbind(DFAll, DF)
        }
        PlotDF <- rbind(PlotDF, DFAll)
        PlotDF <- PlotDF[-Indexes,]
        PlotDF <- dplyr::arrange(PlotDF, Start, Name)
}



###############################
## blockFinder ##
###############################
# NB: function should only be called when PlotDF has at least one entry!
blockFinder <- function(PlotDF){
        if(nrow(PlotDF) > 1){
                DFkBloFind <- data.frame(Time = c(PlotDF$Start, PlotDF$End), Type = c(rep("S", nrow(PlotDF)), rep("E", nrow(PlotDF))), Id = as.integer(rep(rownames(PlotDF),2))) #NB: changes the tz to CEST!!
                #NB: In the following it is important that in case of equal time between an ending and starting event, the ending event comes first, therefore Type is included in the order
                DFkBloFind <- DFkBloFind[order(DFkBloFind$Time, DFkBloFind$Type),]
                DFkBloFind$Adds <- DFkBloFind$Id
                DFkBloFind$Adds[DFkBloFind$Type == "E"] <- -1*DFkBloFind$Adds[DFkBloFind$Type == "E"]
                DFkBloFind$cumSumAdds <- cumsum(DFkBloFind$Adds)
                # every time there is a zero a block ends
                DFkBloFind <- DFkBloFind[DFkBloFind$Type == "E",]
                # constructing a vector where you add 1 after each 0 in DFkBloFind$cumSumAdds
                DFkBloFind$BlockNo <- cumsum(c(1, DFkBloFind$cumSumAdds[1:(nrow(DFkBloFind)-1)]) == 0)
                rleV <- rle(DFkBloFind$BlockNo)
                DFkBloFind$BlockSizes <- rep(rleV$lengths, rleV$lengths)
                DFkBloFind$BlockId <- 0
                DFkBloFind$BlockId[DFkBloFind$BlockSizes != 1] <- rep(order(unique(DFkBloFind$BlockNo[DFkBloFind$BlockSizes != 1])), times = rle(DFkBloFind$BlockNo[DFkBloFind$BlockSizes != 1])[[1]])
                
                PlotDF$blockId <- DFkBloFind$BlockId
                # PlotDF$blockSize <- DFkBloFind$BlockSizes # probably not needed
        } else {
                PlotDF$blockId <- 0
        }
        
        PlotDF
}


###############################
## positionAndWidthAssigner ##
###############################
# you do so by looping through the blocks, assigning each element of a block a slot (which also finds the overall numbers of
# slots). You then find for each elelment of a block the slot of the right side neighbor. 
# Then the startPosition is just (slot of the element - 1) / number of slots (e.g. 3 slots, element is on 2, it should start at 0.33).
# The width is 

positionAndWidthAssigner <- function(PlotDF){
        PlotDF$startPosition <- 0
        PlotDF$Width <- 1
        
        if(any(PlotDF$blockId != 0)){ # if there are no overlapping events, i.e. blocks, this code is skipped
                for(BloId in unique(PlotDF$blockId[PlotDF$blockId > 0])){
                        #BloId <- 1
                        # Pick the Block and order Starts and Ends of events
                        DFkBlock <- PlotDF[PlotDF$blockId == BloId,]
                        DFkBlock <- data.frame(Time = c(DFkBlock$Start, DFkBlock$End), Type = c(rep("S", nrow(DFkBlock)), rep("E", nrow(DFkBlock))), Id = as.integer(rep(rownames(DFkBlock),2)))
                        DFkBlock <- DFkBlock[order(DFkBlock$Time, DFkBlock$Type),]
                        # = assign to each entry the slot and thus also find the total number of slots needed for the block =
                        DFkBlock$Slot <- 0
                        DFkBlock$Slot[1] <- 1
                        for(i in 2:nrow(DFkBlock)){
                                if(DFkBlock$Type[i] == "S"){
                                        # check if a slot is free, which is the case when the number the slot occurs is even
                                        SlotOccurs <- sapply(unique(DFkBlock$Slot[1:(i-1)]), function(x){sum(DFkBlock$Slot[1:(i-1)] == x)})
                                        if(any(SlotOccurs %% 2 == 0)){
                                                # if so put the new element in the smallest free slot
                                                DFkBlock$Slot[i] <- unique(DFkBlock$Slot[1:(i-1)])[which(SlotOccurs %% 2 == 0)[1]] 
                                        } else { # open a new slot
                                                DFkBlock$Slot[i] <- max(DFkBlock$Slot[1:(i-1)]) + 1
                                        }
                                        
                                } else if (DFkBlock$Type[i] == "E"){
                                        DFkBlock$Slot[i] <- DFkBlock$Slot[which(DFkBlock$Id == DFkBlock$Id[i])[1]]
                                }
                        }
                        rm(i)
                        # ==
                        # = then find for each entry the right hand neighbor =
                        DFkBlock$Neighbor <- max(DFkBlock$Slot)+1 # makes it easy to calculate the width of the events later
                        for(i in unique(DFkBlock$Slot)){
                                Indexes <- which(DFkBlock$Slot == i) # NB: always an even number of indixes
                                for(e in 1:(length(Indexes)/2)){
                                        OverlappingSlots <- DFkBlock$Slot[Indexes[2*e-1]:Indexes[2*e]] # Includes the own slot
                                        if(any(OverlappingSlots > i)){
                                                DFkBlock$Neighbor[c(Indexes[2*e-1], Indexes[2*e])] <- min(OverlappingSlots[OverlappingSlots > i])
                                        }
                                }
                        }
                        # ==
                        # == calculate startPosition and Width and put them into PlotDF ==
                        DFkBlock <- DFkBlock[DFkBlock$Type == "S",]
                        PlotDF$startPosition[as.numeric(rownames(PlotDF)) %in% DFkBlock$Id] <- (DFkBlock$Slot-1)/max(DFkBlock$Slot)
                        PlotDF$Width[as.numeric(rownames(PlotDF)) %in% DFkBlock$Id] <- (DFkBlock$Neighbor-DFkBlock$Slot)/max(DFkBlock$Slot)
                }
        }
        PlotDF
        
}