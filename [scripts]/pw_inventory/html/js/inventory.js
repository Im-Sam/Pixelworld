var type = "normal";
var firstTier = 1;
var firstUsed = 0;
var firstItems = new Array();
var secondTier = 1;
var secondUsed = 0;
var secondItems = new Array();

var dragging = false
var origDrag = null;
var draggingItem = null;
var givingItem = null;
var errorHighlightTimer = null;
var mousedown = false;
var docWidth = document.documentElement.clientWidth;
var docHeight = document.documentElement.clientHeight;
var offset = [76,81];
var cursorX = docWidth / 2;
var cursorY = docHeight / 2;
var playerCash = 0;
var usableWasVisible = false
var usablekWasVisible = false

var successAudio = document.createElement('audio');
successAudio.controls = false;
successAudio.volume = 0.25;
successAudio.src = './success.wav';

var failAudio = document.createElement('audio');
failAudio.controls = false;
failAudio.volume = 0.1;
failAudio.src = './fail.wav';

window.addEventListener("message", function (event) {
    switch(event.data.action) {
        case 'display':
            type = event.data.type
    
            if (type === "normal") {
                $('#inventoryTwo').parent().hide();
            } else if (type === "secondary") {
                $('#inventoryTwo').parent().fadeIn();
            }
    
            $(".ui").fadeIn();
            break;
        case 'hide':
            $(".ui").fadeOut();
            $('#inventoryTwo').html('');
            $('#inventoryOne').html('');
            break;
        case 'closeSecondary':
            $('#inventoryTwo').parent().fadeOut('normal', function() {
                $('#inventoryTwo').html('');
            })
            break;
        case 'setItems':
            firstTier = event.data.invTier;
            inventorySetup(event.data.invOwner, event.data.itemList);

            if ($('#search').val() !== '') {
                SearchInventory($('#search').val());
            }

            break;
        case 'setSecondInventoryItems':
            secondTier = event.data.invTier;
            secondInventorySetup(event.data.invOwner, event.data.itemList);

            if ($('#search').val() !== '') {
                SearchInventory($('#search').val());
            }

            break;
        case 'updateCash':
            playerCash = event.data.cash
            break;
        case 'setInfoText':
            $(".info-div").html(event.data.text);
            break;
        case 'nearPlayers':
            if (event.data.players.length > 0) {
                successAudio.play();
                $('.near-players-wrapper').find('.popup-body').html('');
                $.each(event.data.players, function(index, player) {
                    $('.near-players-list .popup-body').append(`<div class="player" data-id="${player.id}">${player.id} - ${player.name}</div>`);
                });
                $('.near-players-wrapper').fadeIn();
            } else {
                DisplayMoveError(origDrag, origDrag, 'Attempted To Give An Item To A Nearest Player, But No Players Are Around.');
            }
            EndDragging();
            break;
        case 'itemUsed':
            ItemUsed(event.data.alerts);
            break;
        case 'showActionBar':
            ActionBar(event.data.items, event.data.timer);

            if (event.data.index != null) {
                ActionBarUsed(event.data.index);
            }
            break;
        case 'showUsableBar':
            if(event.data.items !== undefined) {
                UsableBar("items", event.data.items);
            }
            if(event.data.keys !== undefined) {
                UsableBar("keys", event.data.keys);
            }
            break;
        case 'hideUsableBar':
            if(event.data.method == "items") {
                $('#usable-bar').fadeOut(500);
                usableWasVisible = false
                setTimeout(function() {
                    $('#usable-bar').html('');
                }, 502)
            } else if (event.data.method == "keys") {
                $('#usable-kbar').fadeOut(500);
                usablekWasVisible = false
                setTimeout(function() {
                    $('#usable-kbar').html('');
                }, 502)
            }
            break;
    }
});

function formatCurrency(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function EndDragging() {
    $(origDrag).removeClass('orig-dragging');
    $("#use").removeClass("disabled");
    $("#drop").removeClass("disabled");
    $("#give").removeClass("disabled");
    $(draggingItem).remove();
    origDrag = null;
    draggingItem = null;
    dragging = false;
}

function closeInventory() {
    EndDragging();
    $.post("http://pw_inventory/NUIFocusOff", JSON.stringify({}));
    $('.near-players-wrapper').fadeOut();
    $('#search').val('');
    $('#count').val('0');
}

function inventorySetup(invOwner, items) {
    setupPlayerSlots();
    if(invOwner.name !== undefined || invOwner.name !== null) {
        $('#player-inv-label').html(invOwner.name);
    } else {
        $('#player-inv-label').html(firstTier.label);
    }
    $('#player-inv-id').html(`${firstTier.label.toLowerCase()} - ${invOwner.owner}`);
    invOwner.label = `${firstTier.label.toLowerCase()} - ${invOwner.owner}`;
    $('#inventoryOne').data('invOwner', invOwner);

    firstUsed = 0;
    $.each(items, function (index, item) {
        var slot = $('#inventoryOne').find('.slot').filter(function(){ return $(this).data('slot') === item.slot;});
        firstUsed++;
        var slotId = $(slot).data('slot');
        firstItems[slotId] = item;
        AddItemToSlot(slot, item);
    });

    $('#player-used').html(firstUsed);
    $("#inventoryOne > .slot:lt(5) .item").append('<div class="item-keybind"></div>');

    $('#inventoryOne .item-keybind').each(function(index ) {
        $(this).html(index + 1);
    })
}

function secondInventorySetup(invOwner, items) {
    setupSecondarySlots(invOwner);
    if(invOwner.name !== undefined && invOwner.name !== null) {
        $('#other-inv-label').html(invOwner.name);
    } else {
        $('#other-inv-label').html(secondTier.label);
    }

    if(invOwner.cash !== undefined && invOwner.cash !== null) {
        playerCash = parseInt(invOwner.cash);
    }

    if(invOwner.type > 3 && invOwner.type < 8) {
        $('#other-inv-id').html(`${secondTier.label.toLowerCase()} - ${invOwner.plate}`);
        invOwner.label = `${secondTier.label.toLowerCase()} - ${invOwner.plate}`;
    } else {
        $('#other-inv-id').html(`${secondTier.label.toLowerCase()} - ${invOwner.owner}`);
        invOwner.label = `${secondTier.label.toLowerCase()} - ${invOwner.owner}`;
    }
    $('#inventoryTwo').data('invOwner', invOwner);
    secondUsed = 0;
    $.each(items, function (index, item) {
        if (invOwner.type == 18) {
            item.qty = item.max;
        }

        if (invOwner.type == 21) {
            item.qty = item.max;
        }

        var slot = $('#inventoryTwo').find('.slot').filter(function(){ return $(this).data('slot') === item.slot;});
        secondUsed++;

        if ($(slot).find('.item .shop-cost').length > 0) {
            $(slot).find('.item .shop-cost').html(`$${formatCurrency(item.price)}`)
        }

        var slotId = $(slot).data('slot');
        secondItems[slotId] = item;
        AddItemToSlot(slot, item);
    });
    
    $('#other-used').html(secondUsed);
}

function setupPlayerSlots() {
    $('#inventoryOne').html("");
    $('#player-inv-id').html("");
    $('#inventoryOne').removeData('invOwner');
    $('#player-max').html(firstTier.slots);
    for(i = 1; i <= (firstTier.slots); i++) {
        $("#inventoryOne").append($('.slot-template').clone());
        $('#inventoryOne').find('.slot-template').data('slot', i);
        $('#inventoryOne').find('.slot-template').data('inventory', 'inventoryOne');
        $('#inventoryOne').find('.slot-template').removeClass('slot-template');
    };
}

function setupSecondarySlots(owner) {
    $('#inventoryTwo').html("");
    $('#other-inv-id').html("");
    $('#inventoryTwo').removeData('invOwner');
    $('#other-max').html(secondTier.slots);
    for(i = 1; i <= (secondTier.slots); i++) {
        $("#inventoryTwo").append($('.slot-template').clone());
        $('#inventoryTwo').find('.slot-template').data('slot', i);
        $('#inventoryTwo').find('.slot-template').data('inventory', 'inventoryTwo');

        switch(owner.type) {
            case 1:
                $('#inventoryTwo').find('.slot-template').addClass('player');
                break;
            case 2:
            case 3:
            case 6:
            case 7:
            case 17:
                $('#inventoryTwo').find('.slot-template').addClass('temporary');
                break;
            case 4:
            case 5:
            case 8:
            case 9:
            case 10:
            case 11:
            case 12:
            case 13:
            case 14:
            case 15:
                $('#inventoryTwo').find('.slot-template').addClass('storage');
                break;
            case 16:
                $('#inventoryTwo').find('.slot-template').addClass('evidence');
                break;
            case 18:
                $('#inventoryTwo').find('.slot-template').addClass('shop');
                $('#inventoryTwo').find('.slot-template').find('.item').append('<div class="shop-cost"></div>');
                break;
            case 21:
                $('#inventoryTwo').find('.slot-template').addClass('temporary');
                break;
        }

        $('#inventoryTwo').find('.slot-template').removeClass('slot-template');
    };
}

document.addEventListener('mousemove', function(event) {
    event.preventDefault();
    cursorX = event.clientX,
    cursorY = event.clientY
    if (dragging) {
        if(draggingItem !== undefined && draggingItem !== null) {
            draggingItem.css('left', (cursorX - offset[0]) + 'px');
            draggingItem.css('top', (cursorY - offset[1]) + 'px');
        }
    }
}, true);

$(document).ready(function () {
    $('#inventoryTwo').parent().hide();

    $('#inventoryOne, #inventoryTwo').on('click', '.slot', function(e) {
        itemData = $(this).find('.item').data('item');
        if (itemData == null && !dragging) { return };

        if(dragging) {

            if($(this).data('slot') !== undefined && $(origDrag).data('slot') !== $(this).data('slot') || $(this).data('slot') !== undefined && $(origDrag).data('invOwner') !== $(this).parent().data('invOwner')) {    
                if ($(this).parent().data('invOwner').type == 18) {
                    DisplayMoveError(origDrag, $(this), 'Cannot Put Items In Shop');
                    EndDragging();
                    return;
                }
                
                if ($(this).parent().data('invOwner').type == 21) {
                    DisplayMoveError(origDrag, $(this), 'Cannot Put Items In Crafting');
                    EndDragging();
                    return;
                }
                
                if($(this).find('.item').data('item') !== undefined) {
                    AttemptDropInOccupiedSlot(origDrag, $(this), parseInt($("#count").val()));
                } else {
                    AttemptDropInEmptySlot(origDrag, $(this), parseInt($("#count").val()));
                }
            } else {
                successAudio.play();
            }
            EndDragging();
        } else {
            if (itemData !== undefined) {
                // Store a reference because JS is retarded
                origDrag = $(this)
                AddItemToSlot(origDrag, itemData);
                $(origDrag).data('slot', $(this).find('.item').data('slot'));
                $(origDrag).data('invOwner', $(this).parent().data('invOwner'));
                $(origDrag).addClass('orig-dragging');

                // Clone this shit for dragging
                draggingItem = $(this).clone();
                AddItemToSlot(draggingItem, itemData);
                $(draggingItem).data('slot', $(this).find('.item').data('slot'));
                $(draggingItem).data('invOwner', $(this).parent().data('invOwner'));
                $(draggingItem).addClass('dragging');

                $(draggingItem).css('pointer-events', 'none');
                $(draggingItem).css('left', (cursorX - offset[0]) + 'px');
                $(draggingItem).css('top', (cursorY - offset[1]) + 'px');
                $('.ui').append(draggingItem);

                if (!itemData.usable) {
                    $("#use").addClass("disabled");
                }

                if (!itemData.canRemove || ($(this).parent().data('invOwner') == $('#inventoryTwo').data('invOwner'))) {
                    $("#drop").addClass("disabled");
                    $("#give").addClass("disabled");
                }
            }
            dragging = true;
        }

    });

    $('#close').click(function (event, ui) {
        closeInventory();
    });

    $('.toggle-log').click(function (event, ui) {
        if ($('.inv-log').is(':visible')) {
            $('.inv-log').fadeOut('normal');
        } else {
            $('.inv-log').fadeIn('normal');
        }
    });

    $('#use').click(function (event, ui) {
        if (!$(this).hasClass('disabled')) {
            if(dragging) {
                itemData = $(draggingItem).find('.item').data("item");
                if (itemData.usable) {
                    InventoryLog(`Using ${itemData.label}`);
                    $.post("http://pw_inventory/UseItem", JSON.stringify({
                        owner: $(draggingItem).parent().data('invOwner'),
                        item: itemData
                    }), function(closeUi) {
                        if(closeUi) {
                            closeInventory();
                        }
                    });
                    successAudio.play();
                } else {
                    failAudio.play();
                }
                EndDragging();
            }
        } else {
            DisplayMoveError(origDrag, origDrag, 'Using Disabled');
            EndDragging();
        }
    });

    $("#use").mouseenter(function() {
        if(!$(this).hasClass('disabled')) {
            $(this).addClass('hover');
        }
    }).mouseleave(function() {
        $(this).removeClass('hover');
    });

    $('#give').click(function (event, ui) {
        if (!$(this).hasClass('disabled')) {
            if(dragging) {
                itemData = $(draggingItem).find('.item').data("item");
                let dropCount = parseInt($("#count").val());
    
                if (dropCount === 0 || dropCount > itemData.qty) {
                    dropCount = itemData.qty
                }
    
                if (itemData.canRemove) {
                    $.post("http://pw_inventory/GetSurroundingPlayers", JSON.stringify({}));
                    givingItem = itemData;
                } else {
                    failAudio.play();
                }
            }
        } else {
            DisplayMoveError(origDrag, origDrag, 'Giving Disabled');
            EndDragging();
        }
    });

    $("#give").mouseenter(function() {
        if(!$(this).hasClass('disabled')) {
            $(this).addClass('hover');
        }
    }).mouseleave(function() {
        $(this).removeClass('hover');
    });

    $('#drop').click(function (event, ui) {
        if (!$(this).hasClass('disabled')) {
            if(dragging) {
                itemData = $(draggingItem).find('.item').data("item");
                let dropCount = parseInt($("#count").val());
    
                if (dropCount === 0 || dropCount > itemData.qty) {
                    dropCount = itemData.qty
                }
    
                if (itemData.canRemove) {
                    InventoryLog(`Dropping ${dropCount} ${itemData.label} On Ground`);
                    $.post("http://pw_inventory/DropItem", JSON.stringify({
                        item: itemData,
                        qty: dropCount
                    }));
                    successAudio.play();
                } else {
                    failAudio.play();
                }
                EndDragging();
            }
        } else {
            DisplayMoveError(origDrag, origDrag, 'Droping Disabled');
            EndDragging();
        }
    });

    $("#drop").mouseenter(function() {
        if(!$(this).hasClass('disabled')) {
            $(this).addClass('hover');
        }
    }).mouseleave(function() {
        $(this).removeClass('hover');
    });

    $('#inventoryOne, #inventoryTwo').on('mouseenter', '.slot', function() {
        var itemData = $(this).find('.item').data('item');
        if(itemData !== undefined) {
            $('.tooltip-div').find('.tooltip-name').html(itemData.label);

            if(!itemData.unique) {
                if(itemData.stackable) {
                    $('.tooltip-div').find('.tooltip-uniqueness').html("Not Unique - Stack Max(" + itemData.max + ")");
                } else {
                    $('.tooltip-div').find('.tooltip-uniqueness').html("Not Unique - Not Stackable");
                }
            } else {
                $('.tooltip-div').find('.tooltip-uniqueness').html("Unique (" + itemData.max + ")");
            }

            $('.tooltip-div').find('.tooltip-meta').html('');
            if(itemData.type === 1 || itemData.item === 'license' || itemData.item === "simcard" || itemData.item == "vaultcard" || itemData.item == "moneybag") {
                if(itemData.type === 1) {
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Registered Owner</div> : <div class="meta-val">${itemData.metadata.owner}</div></div>`);
                } else if(itemData.item === 'license') {
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Name</div> : <div class="meta-val">${itemData.metadata.name}</div></div>`);
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Issued On</div> : <div class="meta-val">${itemData.metadata.issuedDate}</div></div>`);
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Height</div> : <div class="meta-val">${itemData.metadata.height}</div></div>`);
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Date of Birth</div> : <div class="meta-val">${itemData.metadata.dob}</div></div>`);
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Phone Number</div> : <div class="meta-val">${itemData.metadata.phone}</div></div>`);
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Citizen ID</div> : <div class="meta-val">${itemData.metadata.id} - ${itemData.metadata.user}</div></div>`);

                    if(itemData.metadata.endorsements !== undefined) {
                        $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Endorsement</div> : <div class="meta-val">${itemData.metadata.endorsements}</div></div>`);
                    }

                    if (itemData.description != null && itemData.description != '') {
                        $('.tooltip-div').find('.tooltip-meta').append(`<hr /><div class="meta-desc">${itemData.description}</div>`);
                    }
            } else if(itemData.item == "vaultcard") {
                if(itemData.metadata.decoded !== undefined && itemData.metadata.decoded === true) {
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-desc">Decoded Information</div>`);
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Bank</div> : <div class="meta-val">${itemData.metaprivate.bankName}</div></div>`);
                    if(itemData.metaprivate.bank == 0) {
                        $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Access Hours</div> : <div class="meta-val">Any</div></div>`);
                    } else {
                        $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Access Hours</div> : <div class="meta-val">${itemData.metaprivate.hours[0]} - ${itemData.metaprivate.hours[1]}</div></div>`);
                    }
                }
                if (itemData.description != null && itemData.description != '') {
                    $('.tooltip-div').find('.tooltip-meta').append(`<hr /><div class="meta-desc">${itemData.description}</div>`);
                }
            } else if(itemData.item === 'moneybag') {
                if(itemData.metadata.amount !== undefined && itemData.metadata.amount !== null) {
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Cash Value</div> : <div class="meta-val">$${itemData.metadata.amount}</div></div>`);
                }
            } else if(itemData.item === 'simcard') {
                $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Network</div> : <div class="meta-val">PixelNet</div></div>`);
                $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Associated Number</div> : <div class="meta-val">${itemData.metadata.number}</div></div>`);
                if (itemData.description != null && itemData.description != '') {
                    $('.tooltip-div').find('.tooltip-meta').append(`<hr /><div class="meta-desc">${itemData.description}</div>`);
                } 
            }
            } else {
                if (itemData.description != null && itemData.description != '') {
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-desc">${itemData.description}</div>`);
                } else {
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-desc">This Item Has No Information</div>');
                }
            }

            $('.tooltip-div').show();
        }
    });

    $('#inventoryOne, #inventoryTwo').on('mouseleave', '.slot', function() {
        $('.tooltip-div').hide();
        $('.tooltip-div').find('.tooltip-name').html("");
        $('.tooltip-div').find('.tooltip-uniqueness').html("");
        $('.tooltip-div').find('.tooltip-meta').html("");
    });

    $("body").on("keyup", function (key) {
        if (Config.closeKeys.includes(key.which)) {
            closeInventory();
        }

        if(key.which === 69) {
            if (type === "trunk") {
                closeInventory();
            }
        }
    });

    $('#count').on('keyup keydown blur', function(e) {
        switch(e.which) {
            case 107: // Numpad Equals
            case 109: // Numpad Minus
            case 110: // Numpad Decimal
            case 187: // =/+
            case 189: // -/_
            case 190: // ./>
                e.preventDefault();
                break;
        }
        if ($(this).val() == '') {
            $(this).val('0');
        } else {
            $(this).val(parseInt($(this).val()))
        }
    });

    $('.exit-popup').on('click', function() {
        givingItem = null;
        $('.near-players-wrapper').fadeOut('normal').promise().then(function() {
            $(this).find('.popup-body').html('');
        });
    });

    $('.popup-body').on('click', '.player', function() {
        if (givingItem != null) {
            let target = $(this).data('id');
            let count = parseInt($("#count").val())

            if (count === 0 || count > givingItem.qty) {
                count = givingItem.qty
            } 

            InventoryLog(`Giving ${count} ${givingItem.label} To Nearby Player With Server ID ${target}`);
            $.post("http://pw_inventory/GiveItem", JSON.stringify({
                target: target,
                item: givingItem,
                count: count
            }), function(status){
                if (status) {
                    $('.near-players-wrapper').fadeOut();

                    if (count == givingItem.qty) {
                        ResetSlotToEmpty(givingItem.slot);
                    }

                    givingItem = null;
                }
            });
        }
    });

    $('#search').on('keyup keydown blur', function(e) {
        SearchInventory($(this).val());
    });

    $('#search-reset').on('click', function() {
        SearchInventory('');
        $('#search').val('');
    });

    $('#count-reset').on('click', function() {
        $('#count').val('0');
    });
});
 
function SearchInventory(searchVal) {
    if (searchVal !== '') {
        $.each(
            $('#search')
                .parent()
                .parent()
                .parent()
                .find('#inventoryOne, #inventoryTwo')
                .children(),
            function(index, slot) {
                let item = $(slot).find('.item').data('item');

                if (item != null) {
                    if (
                        item.label.toUpperCase().includes(searchVal.toUpperCase()) ||
                        item.item.includes(searchVal.toUpperCase())
                    ) {
                        $(slot).removeClass('search-non-match');
                    } else {
                        $(slot).addClass('search-non-match');
                    }
                } else {
                    $(slot).addClass('search-non-match');
                }
            }
        );

    } else {
        $.each(
            $('#search')
                .parent()
                .parent()
                .parent()
                .find('#inventoryOne, #inventoryTwo')
                .children(),
            function(index, slot) {
                $(slot).removeClass('search-non-match');
            }
        );
    }
}

function AttemptDropInEmptySlot(origin, destination, moveQty) {
    let result = ErrorCheck(origin, destination, moveQty)
    if (result === -1) {
        $('.slot.error').removeClass('error');

        let item = origin.find('.item').data('item')

        if (item == null) { return; }

        if(moveQty > item.qty) { moveQty = item.qty; }
        if(moveQty === 0) { moveQty = 1 }

        if(moveQty === item.qty) {
            if (origin.parent().data('invOwner').type != 18 && origin.parent().data('invOwner').type != 21) {
                ResetSlotToEmpty(origin);
            }
            
            item.slot = destination.data('slot');
            AddItemToSlot(destination, item);

            successAudio.play();

            InventoryLog(`Moving ${item.qty} ${item.label} From ${origin.data('invOwner').label} Slot ${origin.data('slot')} To ${destination.parent().data('invOwner').label} Slot ${item.slot}`)
            $.post("http://pw_inventory/MoveToEmpty", JSON.stringify({
                originOwner: origin.parent().data('invOwner'),
                originItem: item,
                destinationOwner: destination.parent().data('invOwner'),
                destinationItem: destination.find('.item').data('item'),
            }));
        } else {
            let item2 = Object.create(item);
            item2.slot = destination.data('slot');
            item2.qty = moveQty;

            if (origin.parent().data('invOwner').type != 18 && origin.parent().data('invOwner').type != 21) {
                item.qty = item.qty - moveQty
                AddItemToSlot(origin, item);
            }
            
            AddItemToSlot(destination, item2);
            successAudio.play();
            
            InventoryLog(`Moving ${moveQty} ${item.label} From ${origin.data('invOwner').label} Slot ${item.slot} To ${destination.parent().data('invOwner').label} Slot ${item.slot}`);
            $.post("http://pw_inventory/SplitStack", JSON.stringify({
                originOwner: origin.parent().data('invOwner'),
                originItem: origin.find('.item').data('item'),
                destinationOwner: destination.parent().data('invOwner'),
                destinationItem: destination.find('.item').data('item'),
                moveQty: moveQty,
            }));
        }
    } else {
        switch(result) {
            case 1:
                DisplayMoveError(origin, destination, "Destination Inventory Owner Was Undefined");
                break;
            case 7:
                DisplayMoveError(origin, destination, "You do not have the required materials to craft.");
                break;
            case 8:
                DisplayMoveError(origin, destination, "You do not have enough cash on you.");
                break;
            case 9:
                DisplayMoveError(origin, destination, "This type of item can not be stored here.");
                break;
        }
    }
}

function AttemptDropInOccupiedSlot(origin, destination, moveQty) {
    let originItem = origin.find('.item').data('item');
    let destinationItem = destination.find('.item').data('item');

    if (originItem == undefined || destinationItem == undefined) { return; }

    if(moveQty > originItem.qty) { 
        moveQty = originItem.qty;
    }

    if(moveQty === 0) { moveQty = 1; }

    let result = ErrorCheck(origin, destination, moveQty);

    if(result === -1) {
        $('.slot.error').removeClass('error');

        if (originItem.itemId === destinationItem.itemId && destinationItem.stackable) {
            if (moveQty != originItem.qty) {
                if (destinationItem.qty + moveQty <= destinationItem.max) {
                    destinationItem.qty += moveQty;

                    if (origin.parent().data('invOwner').type != 18 && origin.parent().data('invOwner').type != 21) {
                        originItem.qty -= moveQty;
                        AddItemToSlot(origin, originItem);
                    }

                    AddItemToSlot(destination, destinationItem);
    
                    successAudio.play();
                    InventoryLog(`Adding ${moveQty} ${originItem.label} In ${origin.data('invOwner').label} Slot ${originItem.slot} To ${destination.parent().data('invOwner').label} Slot ${destinationItem.slot}`);
                    $.post("http://pw_inventory/SplitStack", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originItem: origin.find('.item').data('item'),
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationItem: destination.find('.item').data('item'),
                        moveQty: moveQty,
                    }));
                } else if (destinationItem.qty < destinationItem.max) {
                    let newOrigQty = destinationItem.max - destinationItem.qty;

                    if (origin.parent().data('invOwner').type != 18 && origin.parent().data('invOwner').type != 21) {
                        originItem.qty -= newOrigQty;
                        AddItemToSlot(origin, originItem);
                    }
                    
                    destinationItem.qty = destinationItem.max;
                    AddItemToSlot(destination, destinationItem);
    
                    successAudio.play();
    
                    InventoryLog(`Adding ${originItem.label} To Existing Stack In Inventory ${destination.parent().data('invOwner').label} Slot ${destinationItem.slot}`);
                    $.post("http://pw_inventory/TopoffStack", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originItem: origin.find('.item').data('item'),
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationItem: destination.find('.item').data('item'),
                    }));
                } else {
                    DisplayMoveError(origin, destination, "Stack At Max Items");
                }
            } else {
                if ((destinationItem.qty === destinationItem.max || originItem.qty === originItem.max)) {
                    if (origin.parent().data('invOwner').type == 18) {
                        DisplayMoveError(origin, destination, "Cannot Swap Items With Items In Shop");
                        return;
                    }

                    if (origin.parent().data('invOwner').type == 21) {
                        DisplayMoveError(origin, destination, "Cannot Swap Items With Items In a Crafting Station");
                        return;
                    }

                    destinationItem.slot = origin.data('slot')
                    originItem.slot = destination.data('slot');
        
                    ResetSlotToEmpty(origin);
                    AddItemToSlot(origin, destinationItem);
                    ResetSlotToEmpty(destination);
                    AddItemToSlot(destination, originItem);
                    successAudio.play();
    
                    InventoryLog(`Swapping ${originItem.label} In ${destination.parent().data('invOwner').label} Slot ${originItem.slot} With ${destinationItem.label} In ${origin.data('invOwner').label} Slot ${destinationItem.slot}`);
                    $.post("http://pw_inventory/SwapItems", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originItem: origin.find('.item').data('item'),
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationItem: destination.find('.item').data('item'),
                    }));
                }
                else if(originItem.qty + destinationItem.qty <= destinationItem.max) {
                    if (origin.parent().data('invOwner').type != 18 || origin.parent().data('invOwner').type != 21) {
                        ResetSlotToEmpty(origin);
                    }

                    destinationItem.qty += originItem.qty;
                    AddItemToSlot(destination, destinationItem);
    
                    successAudio.play();

                    InventoryLog(`Merging Stack Of ${originItem.label} In ${origin.data('invOwner').label} Slot ${originItem.slot} To ${destination.parent().data('invOwner').label} Slot ${destinationItem.slot}`);
                    $.post("http://pw_inventory/CombineStack", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originItem: origin.data('slot'),
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationItem: destination.find('.item').data('item'),
                    }));
                } else {
                    let newOrigQty = destinationItem.max - destinationItem.qty;

                    if (origin.parent().data('invOwner').type != 18 && origin.parent().data('invOwner').type != 21) {
                        originItem.qty -= newOrigQty;
                        AddItemToSlot(origin, originItem);
                    }
                    
                    destinationItem.qty = destinationItem.max;
                    AddItemToSlot(destination, destinationItem);
    
                    successAudio.play();
    
                    InventoryLog(`Adding ${originItem.label} To Existing Stack In Inventorry ${destination.parent().data('invOwner').label} Slot ${destinationItem.slot}`);
                    $.post("http://pw_inventory/TopoffStack", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originItem: origin.find('.item').data('item'),
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationItem: destination.find('.item').data('item'),
                    }));
                }
            }

        } else {
            if (origin.parent().data('invOwner').type == 18) {
                DisplayMoveError(origin, destination, "Cannot Swap Items With Items In Shop");
                return;
            }

            if (origin.parent().data('invOwner').type == 21) {
                DisplayMoveError(origin, destination, "Cannot Swap Items With Items In a Crafting Station");
                return;
            }

            destinationItem.slot = origin.data('slot')
            originItem.slot = destination.data('slot');

            ResetSlotToEmpty(origin);
            AddItemToSlot(origin, destinationItem);
            ResetSlotToEmpty(destination);
            AddItemToSlot(destination, originItem);
            successAudio.play();
            
            InventoryLog(`Swapping ${originItem.label} In ${destination.parent().data('invOwner').label} Slot ${originItem.slot} With ${destinationItem.label} In ${origin.data('invOwner').label} Slot ${destinationItem.slot}`);
            $.post("http://pw_inventory/SwapItems", JSON.stringify({
                originOwner: origin.parent().data('invOwner'),
                originItem: origin.find('.item').data('item'),
                destinationOwner: destination.parent().data('invOwner'),
                destinationItem: destination.find('.item').data('item'),
            }));
        }
    } else {
        switch(result) {
            case 1:
                DisplayMoveError(origin, destination, "Destination Inventory Owner Was Undefined");
                break;
            case 2:
                DisplayMoveError(origin, destination, "Max Items In Stack");
                break;
            case 7:
                DisplayMoveError(origin, destination, "You do not have the required materials to craft.");
                break;
            case 8:
                DisplayMoveError(origin, destination, "You do not have enough cash on you.");
                break;
            case 9:
                DisplayMoveError(origin, destination, "This type of item can not be stored here.");
                break;
        }
    }
}

function DisplayMoveError(origin, destination, error) {
    failAudio.play();
    $('.error').removeClass('error');
    clearTimeout(errorHighlightTimer);

    origin.addClass('error');
    destination.addClass('error');
    errorHighlightTimer = setTimeout(function() {
        origin.removeClass('error');
        destination.removeClass('error');
    }, 1000);

    InventoryLog(error);
}

function ErrorCheck(origin, destination, moveQty) {
    var status = -1;

    function shitter(res) {
        return res
    }

    var originOwner = origin.parent().data('invOwner');
    var destinationOwner = destination.parent().data('invOwner');

    if(destinationOwner === undefined) {
        return 1
    }

    var originItem = origin.find('.item').data('item');
    var destinationItem = destination.find('.item').data('item');

    if(originOwner.type == 18) {
        if(moveQty > originItem.max) {
            moveAmount = originItem.max
        } else if(moveQty == 0) {
            moveAmount = 1
        } else {
            moveAmount = moveQty
        }

        if(playerCash < (originItem.price * moveAmount)) {
            return 8
        }
    }

    if(originOwner.type == 21) {
        if(moveQty > originItem.max) {
            moveAmount = originItem.max
        } else if(moveQty == 0) {
            moveQty = 1
        } else {
            moveAmount = moveQty
        }
        if(moveQty > 0) {
            $.ajax({
                async: true,
                url:"http://pw_inventory/doCraftingCheck",
                type:"POST",
                contentType: "application/json",
                data: JSON.stringify({  requestedAmount: moveQty, itemRequested: originItem }),
                success:function(response) {
                    if (response === true) {
                        DisplayMoveError(origin, destination, "You do not have the required materials to craft.");
                        ResetSlotToEmpty(destination)
                    }
               }        
              });
        }
    }

    if (destinationOwner.type == 20 && (originItem.type == "Item" || originItem.type == "Simcard" || originItem.type == "Bankcard")) {
        // Purchased Property Weapons Storage Check
        return 9
    }

    if (destinationOwner.type == 24 && (originItem.type == "Item" || originItem.type == "Simcard" || originItem.type == "Bankcard")) {
        // Motel Room Weapons Storage Check
        return 9
    }

    if (destinationOwner.type > 7 && destinationOwner.type < 16 && (originItem.type == "Weapon" || originItem.type == "Ammo")) {
        // Motel Room and Purchased Property Standard Items Storage Check
        return 9
    }

    return status
}

function ResetSlotToEmpty(slot) {
    slot.find('.item').addClass('empty-item');
    slot.find('.item').css('background-image', 'none');
    slot.find('.item-count').html(" ");
    slot.find('.item-name').html(" ");
    slot.find('.item').removeData("item");
}

function AddItemToSlot(slot, data) {
    slot.find('.empty-item').removeClass('empty-item');
    slot.find('.item').css('background-image', `url(\'img/items/${data.image}\')`); 
    slot.find('.item-count').html(data.qty);
    slot.find('.item-name').html(data.label);
    slot.find('.item').data('item', data);
}

var alertTimer = null;
var hiddenCheck = null;
function ItemUsed(alerts) {
    clearTimeout(alertTimer);
    clearInterval(hiddenCheck);

    $('#use-alert').hide('slide', { direction: 'left' }, 500, function() {
        $('#use-alert .slot').remove();
    });

    if (alerts != null) {
        hiddenCheck = setInterval(function() {
            if (!$('#use-alert').is(':visible') && $('#use-alert .slot').length <= 0) {
                $.each(alerts, function(index, data) {
                    if (data.item != null) {
                        $('#use-alert').append(`<div class="slot alert-${index}""><div class="item"><div class="item-count">${data.qty}</div><div class="item-name">${data.item.label}</div></div><div class="alert-text">${data.message}</div></div>`)
                        .ready(function() {
                            $(`.alert-${index}`).find('.item').css('background-image', `url(\'img/items/${data.item.image}\')`);
                            if (data.item.slot <= 5) {
                                $(`.alert-${index}`).find('.item').append(`<div class="item-keybind">${data.item.slot}</div>`)
                            }
                        });
                    }
                });
    
                clearInterval(hiddenCheck);
        
            
                $('#use-alert').show('slide', { direction: 'left' }, 500, function() {
                    alertTimer = setTimeout(function() {
                        $('#use-alert .slot').addClass('expired');
                        $('#use-alert').hide('slide', { direction: 'left' }, 500, function() {
                            $('#use-alert .slot.expired').remove();
                        });
                    }, 2500);
                });
            }
        }, 100)
    }
}

var actionBarTimer = null;

function UsableBar(reqtype, items) {
    if(reqtype == "items") {
        if(items !== undefined && items !== null) {
            total = items.length
            $('#usable-bar').html('');
            for (let i = 0; i < total; i++) {
                $('#usable-bar').append(`<div class="slot slot-usable-${i}" data-empty="true"><div class="item"><div class="item-name">NONE</div></div></div>`);
                $(`.slot-usable-${i}`).find('.item').css('background-image', 'none');
            }

            $.each(items, function (index, item) {
                $(`.slot-usable-${item.slot - 1}`).find('.item-name').html(item.label);
                $(`.slot-usable-${item.slot - 1}`).find('.item').css('background-image', `url(\'img/items/${item.image}\')`);
            })
            $('#usable-bar').fadeIn(500);
        }
    } else if(reqtype == "keys") {
        if(items !== undefined && items !== null) {
            total = items.length
            $('#usable-kbar').html('');
            for (let i = 0; i < total; i++) {
                $('#usable-kbar').append(`<div class="slot slot-usablek-${i}" data-empty="true"><div class="item"><div class="item-name">NONE</div><div class="item-keybind"></div></div></div>`);
                $(`.slot-usablek-${i}`).find('.item').css('background-image', 'none');
            }

            $.each(items, function (index, item) {
                if (item.key == "1" || item.key == "2" || item.key == "3" || item.key == "4" || item.key == "5" || item.key == "6" || item.key == "7" || item.key == "8" || item.key == "9" || item.key == "0") {
                    keyType = "Number";
                } else {
                    keyType = "Key";
                }
                $(`.slot-usablek-${index}`).find('.item-keybind').html(keyType + ' ' + item.key);
                $(`.slot-usablek-${index}`).find('.item-name').html(item.label);
                $(`.slot-usablek-${index}`).find('.item').css('background-image', `url(\'img/keys/${item.key}.png\')`);
            })
            $('#usable-kbar').fadeIn(500);
        }
    }
}

function ActionBar(items, timer) {
    if ($('#action-bar').is(':visible')) {
        clearTimeout(actionBarTimer);

        for (let i = 0; i < 5; i++) {
            $('#action-bar .slot').removeClass('expired');
            $(`.slot-${i}`).find('.item-count').html('');
            $(`.slot-${i}`).find('.item-name').html('NONE');
            $(`.slot-${i}`).find('.item-keybind').html(i + 1);
            $(`.slot-${i}`).find('.item').css('background-image', 'none');
        }

        $.each(items, function (index, item) {
            $(`.slot-${item.slot - 1}`).find('.item-count').html(item.qty);
            $(`.slot-${item.slot - 1}`).find('.item-name').html(item.label);
            $(`.slot-${item.slot - 1}`).find('.item-keybind').html(item.slot);
            $(`.slot-${item.slot - 1}`).find('.item').css('background-image', `url(\'img/items/${item.image}\')`);
        })
        
            actionBarTimer = setTimeout(function() {
                $('#action-bar .slot').addClass('expired');
                $('#action-bar').hide('slide', { direction: 'down' }, 500, function() {
                    $('#action-bar .slot.expired').remove();
                });
            }, timer == null ? 2000 : timer);
    } else {
        $('#action-bar').html('');
        for (let i = 0; i < 5; i++) {
            
            $('#action-bar').append(`<div class="slot slot-${i}" data-empty="true"><div class="item"><div class="item-count"></div><div class="item-name">NONE</div><div class="item-keybind">${i+1}</div></div></div>`);
            $(`.slot-${i}`).find('.item').css('background-image', 'none');
        }

        $.each(items, function (index, item) {
            $(`.slot-${item.slot - 1}`).html(`<div class="item"><div class="item-count">${item.qty}</div><div class="item-name">${item.label}</div><div class="item-keybind">${item.slot}</div></div>`).data('empty', 'false');
            $(`.slot-${item.slot - 1}`).find('.item').css('background-image', `url(\'img/items/${item.image}\')`);
        })
        
        $('#action-bar').show('slide', { direction: 'down' }, 500, function() {
            actionBarTimer = setTimeout(function() {
                $('#action-bar .slot').addClass('expired');
                $('#action-bar').hide('slide', { direction: 'down' }, 500, function() {
                    $('#action-bar .slot.expired').remove();
                });
            }, timer == null ? 2000 : timer);
        });
    }
}

var usedActionTimer = null;
function ActionBarUsed(index) {
    clearTimeout(usedActionTimer);
    if ($('#usable-bar').is(':visible')) {
        $('#usable-bar').fadeOut(1);
        usableWasVisible = true
    }
    if ($('#usable-kbar').is(':visible')) {
        $('#usable-kbar').fadeOut(1);
        usablekWasVisible = true
    }
    if ($('#action-bar .slot').is(':visible')) {
        if ($(`.slot-${index - 1}`).data('empty') != null) {
            $(`.slot-${index - 1}`).addClass('empty-used');
        } else {
            $(`.slot-${index - 1}`).addClass('used');
        }
        usedActionTimer = setTimeout(function() {
            $(`.slot-${index - 1}`).removeClass('used');
            $(`.slot-${index - 1}`).removeClass('empty-used');
            if(usableWasVisible === true) {
                $('#usable-bar').fadeIn(1);
            }
            if(usablekWasVisible === true) {
                $('#usable-kbar').fadeIn(1);
            }
        }, 1000)
    }
}

function ClearLog() {
    $('.inv-log').html('');
}

function InventoryLog(log) {
    $('.inv-log').html(log + "<br>" + $('.inv-log').html());
}